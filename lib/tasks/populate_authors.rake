require "#{Rails.root}/app/services/authenticated_github_client"

namespace :authors do

  #create a new issue for each author in the DB
  task :populate => :environment do
    puts('Creating an issue for each author...')
    authors = Author.all
    authors.each do |author|
      puts("Creating author #{author.name}")
      issue = AuthenticatedGithubClient.instance.create_issue(ENV["GITHUB_REPO_NAME"], author.name, author.biography)
      author.issue_id = issue.id
      author.save
    end
  end

end
