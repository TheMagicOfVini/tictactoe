# frozen_string_literal: true

class Api::V1::PlayersController < ApplicationController
  RESULT_COLUMNS = { 'win' => :wins, 'loss' => :losses, 'draw' => :draws }.freeze
  # One result write at a time in this process. Two concurrent creates lock each
  # other in SQLite, and the busy timeout blocks every Ruby thread while it waits.
  RESULTS_LOCK = Mutex.new

  # The admin check runs first, so a caller without the token gets 401, not 404.
  before_action :require_admin_token, only: %i[update destroy]
  before_action :set_player, only: %i[show update destroy]
  # GET /players
  def index
    @players = Player.all

    render json: @players
  end

  # GET /players/1
  def show
    render json: @player
  end

  # POST /players
  def create
    @player = Player.new(player_params)


    if @player.save
      render json: @player, status: :created, location: api_v1_player_url(@player)
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/1
  def update
    if @player.update(player_params)
      render json: @player
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # POST /players/results
  # Body: { "name": "...", "result": "win" | "loss" | "draw" }
  # Creates the player if the name is new, then adds 1 to the matching counter.
  def results
    column = RESULT_COLUMNS[params[:result]]
    errors = {}
    errors[:result] = ['must be win, loss or draw'] unless column
    name = params[:name]
    errors[:name] = ["can't be blank"] unless name.is_a?(String) && name.present?
    return render json: errors, status: :unprocessable_entity if errors.any?

    player = RESULTS_LOCK.synchronize do
      found = find_or_create_player(name)
      # One atomic SQL update: SET wins = COALESCE(wins, 0) + 1
      Player.update_counters(found.id, column => 1, touch: true)
      found.reload
    end
    render json: player, status: :ok
  end

  # DELETE /players/1
  def destroy
    @player.destroy
  end

  private

  # PUT, PATCH and DELETE need the X-Admin-Token header to match ENV['ADMIN_TOKEN'].
  # An unset or blank ADMIN_TOKEN denies every request (fail closed).
  def require_admin_token
    expected = ENV['ADMIN_TOKEN'].to_s
    given = request.headers['X-Admin-Token'].to_s
    return if expected.present? && ActiveSupport::SecurityUtils.secure_compare(given, expected)

    render json: { error: 'admin token required' }, status: :unauthorized
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end

  # Another request can create the same name between the find and the insert.
  # Then the unique index or the uniqueness validation fails, and we find that row.
  def find_or_create_player(name)
    Player.find_or_create_by!(name: name)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    Player.find_by!(name: name)
  end


  # Only allow a trusted parameter "white list" through.
  def player_params
    params.require(:player).permit(:name, :wins, :losses, :draws)
  end
end
