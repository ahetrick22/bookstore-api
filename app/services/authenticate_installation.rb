# Instantiate an Octokit client, authenticated as an installation of a
# GitHub App, to run API operations.
module AuthenticateInstallation

  def authenticate_installation(payload_for_installation)

    #if there's a payload, then we are receiving a webhook and will be able to get the installation id to authenticate.
    #this installation id should be set in the local_env.yml file so that we can also initiate requests to populate the authors
    if payload_for_installation
      @installation_id = payload_for_installation['installation']['id']
      puts("Installation ID for local_env.yml is #{@installation_id}")
      @github_repo_name = payload_for_installation['repository']['full_name']
      puts("GitHub repo URL for local_env.yml is #{@github_repo_name}")

    #if there's not a payload, then the installation id & repo name can be grabbed from the local environment. If it's not there, it needs to 
    #be set (can be found by creating & then deleting an issue and checking the logs.)
    else 
      unless ENV["INSTALLATION_ID"].present?
        puts("No installation ID found in .env file. Create a Github issue and check the log to get the installation id.")
        fail
      end
        
      unless ENV["GITHUB_REPO_NAME"].present?
        puts("No GitHub repo name found in .env file. Create a Github issue and check the log to get the full name.")
        abort
      end
    
      @installation_id = ENV["INSTALLATION_ID"]
      @github_repo_name = ENV["GITHUB_REPO_NAME"]
    end
    @installation_token = AuthenticatedGithubClient.instance.app_client.create_app_installation_access_token(@installation_id)[:token]
    @installation_client = Octokit::Client.new(bearer_token: @installation_token)
  end

end