require "#{Rails.root}/app/services/authenticate_installation"

include AuthenticateInstallation

namespace :authors do
  #use Octokit to authenticate and create an installation client
  task :authenticate do
    puts('Authenticating app installation')
    authenticate_installation(nil)
  end

  #create a new issue for each author in the DB
  task :populate => [:authenticate, :environment] do
    puts('Creating an issue for each author...')
    authors = Author.all
    authors.each do |author|
      puts("Creating author #{author.name}")
      issue = @installation_client.create_issue(@github_repo_name, author.name, author.biography)
      author.issue_id = issue.id
      author.save
    end
  end

end
