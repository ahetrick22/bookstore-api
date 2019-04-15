require 'octokit'     #interacts with Github as a bot
require 'json'        # returns the data formatted as JSON
require 'openssl'     # Verifies the webhook signature
require 'jwt'         # Authenticates a GitHub App
require "#{Rails.root}/app/controllers/concerns/authenticate_app"

include Authenticate_App

namespace :authors do
  #use Octokit to authenticate and create an installation client
  task :authenticate do
    puts('Authenticating app & app installation')
    authenticate_app
    #TODO hardcoded installation id & repo name - should these be params?
    authenticate_installation(1)
  end

  #create a new issue for each author in the DB
  task :populate => [:authenticate, :environment] do
    puts('Creating an issue for each author...')
    authors = Author.all
    authors.each do |author|
      puts("Creating author #{author.name}")
      issue = @installation_client.create_issue('ahetrick22/learning-ruby-on-rails', author.name, author.biography)
      author.issue_id = issue.id
      author.save
    end
  end

end
