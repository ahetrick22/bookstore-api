require 'singleton'

class AuthenticatedGithubClient
  # We only want to create one instance of this app client and then use it throughout
  include Singleton

  # Instantiate an Octokit client authenticated as a GitHub App.
  # GitHub App authentication requires that you construct a
  # JWT (https://jwt.io/introduction/) signed with the app's private key,
  # so GitHub can be sure that it came from the app an not altered by
  # a malicious third party.
  def initialize   
    payload_for_jwt = {
      # The time that this JWT was issued, _i.e._ now.
      iat: Time.now.to_i,
  
      # JWT expiration time (10 minute maximum)
      exp: Time.now.to_i + (10 * 60),
  
      # Your GitHub App's identifier number
      iss: ENV['GITHUB_APP_IDENTIFIER']
    }
  
    # Cryptographically sign the JWT.
    jwt = JWT.encode(payload_for_jwt, OpenSSL::PKey::RSA.new(File.read(Rails.root + 'config/key.pem')), 'RS256')
  
    # Create the Octokit client, using the JWT as the auth token.
    @app_client ||= Octokit::Client.new(bearer_token: jwt)
  end

  # This is the only attribute we need access to outside of the class
  attr_accessor :app_client

end

  
  