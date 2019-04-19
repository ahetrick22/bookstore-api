class UpdateAuthorFromIssue < ApplicationService

  attr_reader :payload
  
  def initialize(payload)
    @payload = payload
  end

  #updates an author's bio with the updated description
  def call
  
    #parse the payload to determine which author by the github issue id
    author_issue_id = @payload['issue']['id']

    #grab the bio and update the author
    updated_author_bio = @payload['issue']['body']
    @author = Author.find_by issue_id: author_issue_id
    @author.biography = updated_author_bio
    
    if @author.save
      return true
    else
      return false
    end  
  end

end
