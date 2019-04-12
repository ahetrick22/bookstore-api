require 'octokit'
require 'json'
require 'openssl'     # Verifies the webhook signature
require 'jwt'         # Authenticates a GitHub App
require 'time'        # Gets ISO 8601 representation of a Time object
require 'net/http'
require 'uri'
require 'faker'

class EventHandlerController < ApplicationController

  before_action :get_payload_and_authenticate

  def get_payload_and_authenticate
    get_payload_request(request)
    verify_webhook_signature
    authenticate_app
    # Authenticate the app installation in order to run API operations
    authenticate_installation(@payload)
  end


  def create
    puts('you are creating an event')
    puts("params #{params}")
    puts("action: #{params['action']}")
    case request.env['HTTP_X_GITHUB_EVENT']
    when 'issues'
      if params['action'] === 'create'
        handle_issue_opened_event(params)
      end
      if params['action'] === 'closed'
        handle_issue_closed_event(params)
      end
      if params['action'] === 'edited'
        handle_issue_updated_event(params)
      end
    end

 end

  #adds an authors w/one randomly generated self-published book
  def handle_issue_opened_event(params)

    #parse the params into title as author name and desc as author bio
    author_name = params['issue']['title']
    author_bio = params['issue']['body']

    #generate some fake book data for the author
    book_title = Faker::Book.title
    book_price = Faker::Number.decimal(2)

    #create the author
    author_body = {name: author_name, biography: author_bio}
    @author = Author.new(author_body)

    #create the book
    book_body = {title: book_title, price: book_price, author: @author, publisher: @author}
    @book = Book.new(book_body)

    if @author.save
      if @book.save
        render json: @author, status: :created, location: @author
      end
    else
      render json: @author.errors, status: :unprocessable_entity
    end
   
    
    #send a POST request to /authors w/all params & a POST request to /books w/fake params
    # puts(body)
    # redirect to ('http://localhost:3000/authors'), body
  end

  #deletes an author and their books
  def handle_issue_closed_event(params)
    #parse the params to determine which author
    author_name = params['issue']['title']
    author_id = params['issue']['id']
    #send a DELETE request to authors/:id & make sure books are deleted too
    puts(author_name)
  end

  #updates an author's bio with the updated description
  def handle_issue_updated_event(params)
    #parse the payload to determine which author
    author_id = params['issue']['id']
    updated_author_bio = params['issue']['body']

    #send a PUT request to /authors/:id with info to update
  end

  # Saves the raw payload and converts the payload to JSON format
  def get_payload_request(request)
    # request.body is an IO or StringIO object
    # Rewind in case someone already read it
    request.body.rewind
    # The raw text of the body is required for webhook signature verification
    @payload_raw = request.body.read
    begin
      @payload = JSON.parse @payload_raw
    rescue => e
      fail  "Invalid JSON (#{e}): #{@payload_raw}"
    end
  end

  # Instantiate an Octokit client authenticated as a GitHub App.
  # GitHub App authentication requires that you construct a
  # JWT (https://jwt.io/introduction/) signed with the app's private key,
  # so GitHub can be sure that it came from the app an not altererd by
  # a malicious third party.
  def authenticate_app
    payload = {
        # The time that this JWT was issued, _i.e._ now.
        iat: Time.now.to_i,

        # JWT expiration time (10 minute maximum)
        exp: Time.now.to_i + (10 * 60),

        # Your GitHub App's identifier number
        iss: ENV['GITHUB_APP_IDENTIFIER']
    }

    # Cryptographically sign the JWT.
    jwt = JWT.encode(payload, OpenSSL::PKey::RSA.new(File.read(Rails.root + 'config/key.pem')), 'RS256')

    # Create the Octokit client, using the JWT as the auth token.
    @app_client ||= Octokit::Client.new(bearer_token: jwt)
  end

  # Instantiate an Octokit client, authenticated as an installation of a
  # GitHub App, to run API operations.
  def authenticate_installation(payload)
    @installation_id = payload['installation']['id']
    @installation_token = @app_client.create_app_installation_access_token(@installation_id)[:token]
    @installation_client = Octokit::Client.new(bearer_token: @installation_token)
  end

  # Check X-Hub-Signature to confirm that this webhook was generated by
  # GitHub, and not a malicious third party.
  #
  # GitHub uses the WEBHOOK_SECRET, registered to the GitHub App, to
  # create the hash signature sent in the `X-HUB-Signature` header of each
  # webhook. This code computes the expected hash signature and compares it to
  # the signature sent in the `X-HUB-Signature` header. If they don't match,
  # this request is an attack, and you should reject it. GitHub uses the HMAC
  # hexdigest to compute the signature. The `X-HUB-Signature` looks something
  # like this: "sha1=123456".
  # See https://developer.github.com/webhooks/securing/ for details.
  def verify_webhook_signature
    their_signature_header = request.env['HTTP_X_HUB_SIGNATURE'] || 'sha1='
    method, their_digest = their_signature_header.split('=')
    our_digest = OpenSSL::HMAC.hexdigest(method, ENV['GITHUB_WEBHOOK_SECRET'], @payload_raw)
    halt 401 unless their_digest == our_digest

  end

end
