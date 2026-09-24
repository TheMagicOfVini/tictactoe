# frozen_string_literal: true

require 'rails_helper'

# Two requests run at the same time on two threads, as two Puma threads do.
# Each thread needs its own database connection, so these examples do not run
# inside a test transaction. They delete the players they make.
RSpec.describe 'Players API concurrent results', type: :request do
  self.use_transactional_tests = false

  # The test env loads classes on first use. Two threads that load the same
  # controller at the same time fail, so load everything first.
  before(:all) { Rails.application.eager_load! }

  # Puma threads switch at each IO wait. Here a request takes a few ms and Ruby
  # switches threads only every 100 ms, so one request could finish before the
  # other starts. A short sleep after each SQL statement lets the other thread
  # run between the statements of a transaction.
  around do |example|
    yield_after_sql = ->(*) { sleep 0.02 }
    ActiveSupport::Notifications.subscribed(yield_after_sql, 'sql.active_record') { example.run }
  end

  after { Player.delete_all }

  # Sends each body on its own thread. The threads start together.
  # Returns [status, seconds] for each body, in the order of the bodies.
  def post_results_concurrently(*bodies)
    app = Rack::MockRequest.new(Rails.application)
    start = Queue.new
    threads = bodies.map do |body|
      Thread.new do
        Thread.current.report_on_exception = false
        start.pop
        ActiveRecord::Base.connection_pool.with_connection do
          began = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          response = app.post('/api/v1/players/results', input: body.to_json,
                                                         'CONTENT_TYPE' => 'application/json')
          [response.status, Process.clock_gettime(Process::CLOCK_MONOTONIC) - began]
        end
      end
    end
    bodies.size.times { start << true }
    threads.map(&:value)
  end

  def expect_fast_200s(results)
    expect(results.map(&:first)).to all(eq(200))
    expect(results.map(&:last)).to all(be < 1)
  end

  # Repeat each case, because one run can miss the race.
  RUNS = 5

  it 'saves two new names sent at the same time' do
    RUNS.times do |run|
      Player.delete_all
      results = post_results_concurrently({ name: "Ann#{run}", result: 'win' },
                                          { name: "Bob#{run}", result: 'loss' })

      expect_fast_200s(results)
      expect(Player.find_by!(name: "Ann#{run}").attributes).to include('wins' => 1, 'losses' => 0, 'draws' => 0)
      expect(Player.find_by!(name: "Bob#{run}").attributes).to include('wins' => 0, 'losses' => 1, 'draws' => 0)
    end
  end

  it 'saves one player for the same new name sent twice at the same time' do
    RUNS.times do |run|
      Player.delete_all
      results = post_results_concurrently({ name: "Zed#{run}", result: 'win' },
                                          { name: "Zed#{run}", result: 'draw' })

      expect_fast_200s(results)
      expect(Player.where(name: "Zed#{run}").count).to eq(1)
      expect(Player.find_by!(name: "Zed#{run}").attributes).to include('wins' => 1, 'losses' => 0, 'draws' => 1)
    end
  end

  it 'saves a new name and a known name sent at the same time' do
    RUNS.times do |run|
      Player.delete_all
      Player.create!(name: "Kim#{run}", wins: 2)
      results = post_results_concurrently({ name: "New#{run}", result: 'win' },
                                          { name: "Kim#{run}", result: 'win' })

      expect_fast_200s(results)
      expect(Player.find_by!(name: "New#{run}").wins).to eq(1)
      expect(Player.find_by!(name: "Kim#{run}").wins).to eq(3)
    end
  end
end
