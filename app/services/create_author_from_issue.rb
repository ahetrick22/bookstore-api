class CreateAuthorFromIssue < ApplicationService

  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end
  
  #adds an author w/one randomly generated self-published book
  def call
    
    #parse the payload into title as author name and body as author bio
    author_name = @payload['issue']['title']
    author_bio = @payload['issue']['body']
    author_issue_id = @payload['issue']['id']

    #generate some fake book data for the author
    book_title = Faker::Book.title
    book_price = Faker::Number.decimal(2)

    #create the author and make sure that both the author and the book save in one transaction
    author_body = {name: author_name, biography: author_bio, issue_id: author_issue_id}
    begin
      @author = Author.new(author_body)
      ApplicationRecord.transaction do
        @author.save!
        book_body = {title: book_title, price: book_price, author: @author, publisher: @author}
        @book = @author.books.create!(book_body)
      end
      return true
    rescue => e
      return false
    end
  end
end