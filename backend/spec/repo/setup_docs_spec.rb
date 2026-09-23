# frozen_string_literal: true

require 'spec_helper'
require 'open3'

# E5-S1 / E6-S9: the setup docs and the git index stay in line with the tooling.
# These examples read files in the repo, not app behaviour, so they need no Rails.
RSpec.describe 'Setup docs and tooling' do
  def repo_root
    File.expand_path('../../..', __dir__)
  end

  def generated_files
    %w[
      backend/db/development.sqlite3
      backend/db/test.sqlite3
      backend/log/development.log
      backend/db/.seeds.rb.swp
    ]
  end

  def repo_file(path)
    File.read(File.join(repo_root, path))
  end

  def git(*args)
    out, status = Open3.capture2e('git', *args, chdir: repo_root)
    [out.strip, status]
  rescue Errno::ENOENT
    [nil, nil]
  end

  def skip_without_git
    _, status = git('rev-parse', '--is-inside-work-tree')
    skip 'git is not available in this environment' if status.nil? || !status.success?
  end

  # "https://github.com/owner/repo.git" and "git@github.com:owner/repo.git"
  # both become "github.com/owner/repo".
  def normalise_url(url)
    url.sub(%r{\A[a-z+]+://}, '').sub(/\A[^@]+@/, '').sub(':', '/').sub(/\.git\z/, '')
  end

  describe 'Ruby version' do
    let(:pinned) { repo_file('backend/.ruby-version').strip }

    it 'pins the same Ruby version in .ruby-version, the Gemfile and the Dockerfile' do
      gemfile = repo_file('backend/Gemfile')[/^ruby\s+['"]([^'"]+)['"]/, 1]
      dockerfile = repo_file('Dockerfile')[/^FROM\s+ruby:([\d.]+)/, 1]

      expect(pinned).to eq('2.6.1')
      expect(gemfile).to eq(pinned)
      expect(dockerfile).to eq(pinned)
    end

    it 'names that Ruby version in every place in the README' do
      readme = repo_file('README.md')
      mentions = {
        'requirements line' => readme[/Ruby\s+([\d.]+)/, 1],
        'rvm install' => readme[/rvm install\s+([\d.]+)/, 1],
        'rvm use' => readme[/rvm use\s+ruby-([\d.]+)/, 1]
      }

      mentions.each do |place, version|
        expect(version).to eq(pinned), "the README #{place} says Ruby #{version.inspect}, not #{pinned}"
      end
    end
  end

  describe 'clone URL' do
    it 'clones the origin remote' do
      skip_without_git
      origin, status = git('config', '--get', 'remote.origin.url')
      skip 'this checkout has no origin remote' unless status.success? && !origin.empty?

      clone_url = repo_file('README.md')[/git clone\s+(\S+)/, 1]

      expect(clone_url).not_to be_nil
      expect(normalise_url(clone_url)).to eq(normalise_url(origin))
    end
  end

  describe 'generated files' do
    it 'does not track the databases, the log or the swap file' do
      skip_without_git
      tracked, = git('ls-files', '--', *generated_files)

      expect(tracked).to eq('')
    end

    it 'ignores the databases, the log and the swap file' do
      skip_without_git
      generated_files.each do |path|
        _, status = git('check-ignore', '-q', path)
        expect(status).to be_success, "#{path} is not git-ignored"
      end
    end
  end
end
