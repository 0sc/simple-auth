require "http/client"
require "./simple-auth/*"

module Simple::Auth
  macro default_layout_view_for(view)
    render "src/views/#{{{view}}}.ecr", "src/views/layouts/default.ecr"    
  end

  get "/" do
    default_layout_view_for "index"
  end

  get "/login" do |env|
    url = "https://accounts.google.com/o/oauth2/v2/auth?scope=email%20profile&state=security_token&redirect_uri=http%3A%2F%2Flocalhost:3000%2Fcallback&response_type=code&client_id=46513068871-6iqq8tj6nitmjfkg0pmcoa3ta9l4d9g9.apps.googleusercontent.com"
    env.redirect url
  end

  get "/callback" do |env|
    # puts env.params.query["error"]?
    # puts env.params.query["code"]?
    # puts env.params.query["state"]

    # check for response error here

    exchange_url = "https://www.googleapis.com/oauth2/v4/token"
    payload = {
      "code" => env.params.query["code"]?,
      "client_id" => ENV["OAUTH_CLIENT_ID"],
      "client_secret" => ENV["OAUTH_CLIENT_SECRET"],
      "redirect_uri" => "http://localhost:3000/callback",
      "grant_type" => "authorization_code"
    }

    response = HTTP::Client.post_form(exchange_url, payload)
    # puts response.status_code 
    # puts response.body
    resp = JSON.parse(response.body)

    # check for response error here
    # puts resp["access_token"]

    user_info = HTTP::Client.get("#{GoogleUserInfoURL}#{resp["access_token"]}")

    # check for response error here
    # puts user_info.status_code
    # puts user_info.body
    user = JSON.parse(user_info.body)

    # return user information

    env.session.string("user_id", user["id"].as_s)
    env.session.string("user_name", user["displayName"].as_s)
    env.session.string("user_image", user["image"]["url"].as_s)

    env.redirect "/home"
  end

  get "/home" do |env|
    env.redirect "/login" unless env.session.string?("user_id")
    user_name = env.session.string?("user_name")
    user_image = env.session.string?("user_image")
    default_layout_view_for "home"   
  end
end

port = ENV["PORT"].to_i if ENV["PORT"]?
Kemal.run port