module GoogleOauth
    class APIClient
        # add class method to load client secret.json
        def self.setup(client_id : String, client_secret : String)
            new(client_id, client_secret)
        end

        def initialize(client_id, client_secret)

        end
    end
end