class DeleteAuthorFromIssue < ApplicationService

  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  #deletes an author and their books
  def call

    #parse the payload to determine which author by the github issue id
    author_issue_id = @payload['issue']['id']

    #delete the author (& associated books based on dependency assigned in model)
    @author = Author.find_by issue_id: author_issue_id

    if @author.destroy
      return true
    else 
      return false
    end
  end
end
