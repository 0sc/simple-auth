require "http/client"

module GoogleOauth
    GoogleUserInfoURL = "https://www.googleapis.com/plus/v1/people/me?access_token="

    class UserInfo
        def self.get_user_basic_info(access_token)
            response = HTTP::Client.get("#{GoogleUserInfoURL}#{access_token}")
            body = JSON.parse response.body
            # check response code 
            raise "#{body["error"]?}" if response.status_code > 300
            body
        end
    end
end