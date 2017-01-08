require "kemal"
require "kemal-session"
require "./../google-oauth/*"

Session.config.secret = "some_secret"
PORT = (ENV["PORT"]? || "3000").to_i
HOST = ENV["HOST"]? || "http://localhost:#{PORT}"

GoogleAuthClient = GoogleOauth::APIClient.setup
GoogleAuthClient.callback_url = "#{HOST}/callback"