require "kemal"
require "kemal-session"

Session.config.secret = "some_secret"
GoogleUserInfoURL = "https://www.googleapis.com/plus/v1/people/me?access_token="
