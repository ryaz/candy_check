require 'byebug'

module CandyCheck
  module PlayStore
    # A client which uses the official Google API SDK to authenticate
    # and request product information from Google's API.
    #
    # @example Usage
    #   config = Config.new({...})
    #   client = Client.new(config)
    #   client.verify('my.bundle', 'product_1', 'a-very-long-secure-token')
    #   # ... multiple calls from now on
    #   client.verify('my.bundle', 'product_1', 'another-long-token')
    class Client
      # Error thrown if the discovery of the API wasn't successful
      class DiscoveryError < RuntimeError; end

      # Initializes a client using a configuration.
      # @param config [ClientConfig]
      def initialize(config)
        @config = config
        auth = ::Google::Auth::ServiceAccountCredentials.make_creds(scope: config.class::SCOPE)
        @api_client = ::Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
        @api_client.authorization = auth
      end

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param product_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [Hash] result of the API call
      def verify(package, product_id, token)
        api_client.get_purchase_product(package, product_id, token)
      end

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param subscription_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [Hash] result of the API call
      def verify_subscription(package, subscription_id, token)
        api_client.get_purchase_subscription(package, subscription_id, token) do |result, error|
          if error
            JSON.parse error.body
          else
            result
          end
        end
      end

      private

      attr_reader :config, :api_client, :rpc
    end
  end
end
