class EventHandlerController < ApplicationController

  include VerifyWebhook

  before_action :get_payload_and_verify_webhook

  def create
    #make sure that this is a user-created issue & not a bot-created one (from the populate authors task)
    return unless @payload['sender']['type'] == "User"
    
    #make sure the event type is 'issues'
    return unless request.env['HTTP_X_GITHUB_EVENT'] == 'issues'

    case @payload['action'] 
      when 'opened'
        service_success = CreateAuthorFromIssue.call(@payload)
      when 'closed'
        service_success = DeleteAuthorFromIssue.call(@payload)
      when 'edited'
        service_success = UpdateAuthorFromIssue.call(@payload)
    end

    # if service_success is true, then the operation was performed successfully on the author instance
    # otherwise we should return the errors
    if service_success
      render json: @author, status: :created, location: @author
    else
      render json: @author.errors, status: :unprocessable_entity
    end  
  end
end