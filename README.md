# BOOKSTORE-API

This app uses Ruby version 2.6.0.

## INSTALL AND RUN THE GITHUB APP INTEGRATION LOCALLY

1) Clone down this repo locally and run `bundle install`.
2) Click to create a new GitHub app at [the GitHub apps page](https://github.com/settings/apps). Give it a name. Steps 3-8 will be used to complete the remaining fields.
3) Create a webhook URL. If you don't have the smee client installed, run `npm install --global smee-client` (unless you have another tool like ngrok or localtunnel that you prefer). Then generate a Smee channel from [smee.io](https://smee.io).
4) Get that URL and replace "YOUR_URL_HERE" with it in this terminal command: `smee URL smee --url YOUR_URL_HERE --path /event_handler --port 3000`. Leave that terminal running in the background.
5) Paste that URL into your Homepage URL and Webhook URL of your new GitHub app.
6) Set a webhook secret. Run `ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'` in your terminal and paste in the output to the Webhook Secret of your GitHub app.
7) Go to the `config/local_env_example.yml` file in the project and paste the webhook secret inside the double quotes next to GITHUB_WEBHOOK_SECRET. Rename the file to `local_env.yml` and uncomment the variable lines.
8) Under permissions for the new GitHub app, allow read & write access for repository contents, issues, and repository webhooks. Under subscribe, check the box to subscribe to issues. Then create the app.
9) Get the App ID under the "About" section and paste it into the double quotes next to GITHUB_APP_IDENTIFIER in `local_env.yml`.
10) Scroll to the bottom of the About section and generate a private key.
11) Open the private key in a text editor and copy it as-is into a new file in the project: `config/key.pem`. It should be on several lines, beginning with "-----BEGIN RSA PRIVATE KEY-----" and ending with "-----END RSA PRIVATE KEY-----".
12) Go to "Install app" on the left menu and install it onto your desired test repository.
13) In the project directory, run `rails db:seed` and then start your server with `rails server --binding 0.0.0.0`. 
14) Go to your GitHub repository and create an issue, then close it. In your rails server terminal, you should now see a line with the installation id for the app (probably a 6 digit number). Paste that into your `local_env.yml` file inside the double quotes. 
15) In a new terminal in your project folder, run `rake authors:populate`. You should see each author in your DB listed out in the terminal, and once the rake task is complete, refresh your issues list on the GitHub repo and you'll see each author there (title is name, description is biography). 

You are now ready to interact with the app - create a new issue to add an author to your DB, update an issue description to update the author's bio, or close the issue to delete the author and their books from the DB.

## STEPS TO RUN JUST THE API LOCALLY
1) Clone down this repo locally and run `bundle install` then `rails db:seed`.
2) In a terminal, run `rails server --binding 0.0.0.0`.