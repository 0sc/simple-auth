require "http/client"

module GoogleOauth
    class APIClient
        # add class method to load client secret.json
        def self.setup(client_id = ENV["OAUTH_CLIENT_ID"]?, client_secret = ENV["OAUTH_CLIENT_SECRET"]?)
            if client_id == nil || client_secret == nil 
                # load from file
                client_id = "hello"
                client_secret = "hi"
            end
            client_id = client_id.as String
            client_secret = client_secret.as String
            new(client_id, client_secret)
        end

        property :callback_url, :security, :google_login_url, :response_type, client_id, client_secret
        getter :scope

        @scope = ["email", "profile"]
        @callback_url = "/auth/callback"
        @security = ""
        @response_type = "code"
        @google_login_url = "https://accounts.google.com/o/oauth2/v2/auth?"

        def initialize(client_id : String, client_secret : String)
            @client_id = client_id
            @client_secret = client_secret
        end

        def scope=(request_scope : Array)
            @scope = request_scope
        end
        
        def escape(value : String)
            URI.escape(value)
        end

        def unescape(value : String)
            URI.unescape(value)
        end

        def build_google_login_url
            puts "Warning: Callback URL is not setup" unless callback_url 

            url = ""
            url = "#{url}scope=#{escape(scope.join(" "))}&" if scope
            url = "#{url}state=#{escape(security)}&" if security
            url = "#{url}redirect_uri=#{escape(callback_url)}&" if callback_url
            url = "#{url}response_type=#{escape(response_type)}&" if response_type
            url = "#{url}client_id=#{escape(client_id)}&" if response_type

            "#{google_login_url}#{url}"
        end

        def handle_callback(query)
            return exchange_callback_token(query["code"]) if query["code"]?
            raise "#{query["error"]?}" 
        end

        def exchange_callback_token(code)
            exchange_url = "https://www.googleapis.com/oauth2/v4/token"

            payload = {
                "code" => code,
                "client_id" => client_id,
                "client_secret" => client_secret,
                "redirect_uri" => callback_url,
                "grant_type" => "authorization_code"
                }
            HTTP::Client.post_form(exchange_url, payload)
        end

        def handle_exchange_response(response)
            # parse response body
            body = JSON.parse(response.body)
            # check response for access_token
            raise "#{body["error"]?}" unless body["access_token"]?
            body
        end
    end
end