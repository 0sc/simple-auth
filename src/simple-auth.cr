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
    root_url = env.request.host_with_port
    env.redirect GoogleAuthClient.build_google_login_url
  end

  get "/callback" do |env|
    response = GoogleAuthClient.handle_callback(env.params.query)
    resp = GoogleAuthClient.handle_exchange_response(response)

    user = GoogleOauth::UserInfo.get_user_basic_info(resp["access_token"]?)

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

Kemal.run PORT