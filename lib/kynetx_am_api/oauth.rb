module KynetxAmApi
  require 'oauth'
  require 'json'

  class Oauth

    attr_accessor :request_token
    attr_accessor :account_consumer
    attr_accessor :api_consumer
    attr_accessor :user
    attr_accessor :access_token


    def initialize(user=nil)
      @user = KynetxAmApi::User.new(user)
      if @user.oauth_verifier
        access_tokens
      end
    end

    def get_access_token
      return @access_token if @access_token
      return @access_token = OAuth::AccessToken.new(get_api_consumer, @user.access_token, @user.access_secret)
    end

    def get_request_token
      return @request_token if @request_token
      return @request_token = get_account_consumer.get_request_token
    end


    def self.accounts_server_url=(v)
      @@accounts_server_url = v
    end
    
    def self.api_server_url=(v)
      @@api_server_url = v
    end
    
    def self.consumer_key=(v)
      @@consumer_key = v
    end
    
    def self.consumer_secret=(v)
      @@consumer_secret = v
    end

    private

   
    def access_tokens
      access_request_token = OAuth::RequestToken.new(get_account_consumer, @user.request_token, @user.request_secret)
      access_token_data = access_request_token.get_access_token :oauth_verifier => @user.oauth_verifier
      @user.access_token = access_token_data.token
      @user.access_secret = access_token_data.secret

    end

    def get_account_consumer
      return @account_consumer if @account_consumer
      return @account_consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret, {
              :site               => @@accounts_server_url,
              :scheme             => :header,
              :method             => :get,
              :request_token_path => "/oauth/request_token",
              :access_token_path  => "/oauth/access_token",
              :authorize_path     => "/oauth/authorize",
              :oauth_version      => "1.0a"
      })


    end


    def get_api_consumer
      return @api_consumer if @api_consumer
      return @api_consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret, {
              :site               => @@api_server_url,
              :scheme             => :header,
              :method             => :get,
              :request_token_path => "/oauth/request_token",
              :access_token_path  => "/oauth/access_token",
              :authorize_path     => "/oauth/authorize",
              :oauth_version      => "1.0a"
      })


    end

  end
end