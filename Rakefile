namespace :deploy do
  PUBLISH_DIR    = 'build'
  GIT_URL = 'git@github.com:mabreys/mabreys.github.io.git'
  GIT_REMOTE = 'origin'
  PUBLISH_BRANCH = 'master'
  DEVELOP_BRANCH = 'middleman'

  def git_remote
    GIT_REMOTE
  end

  def develop_branch
    DEVELOP_BRANCH
  end

  def git_remote_develop_branch
    "#{git_remote}/#{develop_branch}"
  end

  def git_current_branch
    `git rev-parse --abbrev-ref HEAD`.chomp
  end

  def git_current_branch_sha
    `git rev-parse HEAD`.chomp
  end

  def git_tracking_branch
    `git for-each-ref --format='%(upstream:short)' #{`git symbolic-ref -q HEAD`}`.chomp
  end

  def git_current_branch_is_up_to_date_with_remote?
    behind, ahead = `git rev-list --left-right --count #{git_tracking_branch}...HEAD`.chomp.split.map(&:to_i)
    if behind + ahead == 0
      true
    else
      puts "#{git_current_branch} is behind #{git_tracking_branch} by #{behind} commit(s)"  unless behind == 0
      puts "#{git_current_branch} is ahead of #{git_tracking_branch} by #{ahead} commit(s)" unless ahead == 0
      false
    end
  end

  def root(&block)
    File.dirname(__FILE__).tap do |root|
      return result = if block_given?
        pwd == root ? yield : cd(root, &block)
      end
    end
  end

  def git_status_clean?
    `git status --porcelain`.tap do |output|
      if system("test -z '#{output}'")
        return true
      else
        puts output
        return false
      end
    end
  end

  def local_branch_current_with_remote?
    puts "Fetching remote..."
    system("git fetch #{git_remote}") and git_current_branch_is_up_to_date_with_remote?
  end

  def check_that(message, &expectaion)
    message = "============= #{message} ============="
    if expectaion.call
      puts message.gsub(' IS ', ' IS ')
    else
      fail message.gsub(' IS ', ' IS NOT ')
    end
  end

  task :ensure_development do
    root do
      check_that("#{develop_branch} branch IS checked out") { git_current_branch == develop_branch }
      check_that("#{develop_branch} branch IS clean") { git_status_clean? }
      check_that("#{develop_branch} branch IS up to date with #{git_remote_develop_branch}") { local_branch_current_with_remote? }
    end
  end

  task :publish do
    develop_branch = root { git_current_branch }
    develop_branch_sha = root { git_current_branch_sha }

    rm_rf PUBLISH_DIR
    mkdir PUBLISH_DIR
    system "git clone #{GIT_URL} #{PUBLISH_DIR}"
    system './bin/middleman build'

    cd PUBLISH_DIR do
      system "git add --all ."
      system "git commit -m 'Site built at #{Time.now.utc} from #{develop_branch} ref #{develop_branch_sha}'"
      system "git push #{git_remote} #{PUBLISH_BRANCH}"
    end

    rm_rf PUBLISH_DIR
  end


  desc "Generate flat files and deploy to GitHub Pages"
  task github: [:ensure_development, :publish]

end
