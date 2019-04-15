require 'octokit'     # interacts with Github as a bot
require 'json'        # returns the data formatted as JSON
require 'openssl'     # Verifies the webhook signature
require 'jwt'         # Authenticates a GitHub App
require 'time'        # Gets ISO 8601 representation of a Time object
require 'faker'       # generates fake book data

class EventHandlerController < ApplicationController

  include Authenticate_App

  before_action :get_payload_and_authenticate

  def create
    #make sure that this is a user-created issue & not a bot-created one (from the populate authors task)
    if @payload['sender']['type'] == "User"
      case request.env['HTTP_X_GITHUB_EVENT']
      when 'issues'
        if @payload['action'] === 'opened'
          handle_issue_opened_event(@payload)
        end
        if @payload['action'] === 'closed'
          handle_issue_closed_event(@payload)
        end
        if @payload['action'] === 'edited'
          handle_issue_updated_event(@payload)
        end
      end
    end
  end

  #adds an author w/one randomly generated self-published book
  def handle_issue_opened_event(payload)
    #parse the payload into title as author name and body as author bio
    author_name = payload['issue']['title']
    author_bio = payload['issue']['body']
    author_issue_id = payload['issue']['id']

    #generate some fake book data for the author
    book_title = Faker::Book.title
    book_price = Faker::Number.decimal(2)

    #create the author and save
    author_body = {name: author_name, biography: author_bio, issue_id: author_issue_id}
    @author = Author.new(author_body)
    @author.save

    #create the book
    book_body = {title: book_title, price: book_price, author: @author, publisher: @author}
    @book = author.books.create(book_body)

    #make sure that both the book & author have saved appropriately before returning the new author
      if @book.save
        render json: @author, status: :created, location: @author
      else
        render json: @author.errors, status: :unprocessable_entity
      end
    end

  #deletes an author and their books
  def handle_issue_closed_event(payload)

    #parse the payload to determine which author by the github issue id
    author_issue_id = payload['issue']['id']

    #delete the author (& associated books based on dependency assigned in model)
    author_to_delete = Author.find_by issue_id: author_issue_id
    author_to_delete.destroy
  end

  #updates an author's bio with the updated description
  def handle_issue_updated_event(payload)    
  
    #parse the payload to determine which author by the github issue id
    author_issue_id = payload['issue']['id']

    #grab the bio and update the author
    updated_author_bio = payload['issue']['body']
    @author_to_update = Author.find_by issue_id: author_issue_id
    @author_to_update.biography = updated_author_bio

    if @author_to_update.save
      render json: @author_to_update, status: :created, location: @author_to_update
    else
      render json: @author_to_update.errors, status: :unprocessable_entity
    end  
  end

end