module CandyCheck
  module PlayStore
    # Verifies a purchase token against the Google API
    # The call return either an {Receipt} or an {VerificationFailure}
    class SubscriptionVerification < Verification
      # Performs the verification against the remote server
      # @return [Subscription] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        if valid?
          Subscription.new(@response.to_h)
        else
          VerificationFailure.new(@response['error'])
        end
      end

      private

      def valid?
        return unless @response.class.name.demodulize == 'SubscriptionPurchase'

        ok_kind = @response.kind == 'androidpublisher#subscriptionPurchase'
        @response.expiry_time_millis && ok_kind
      end

      def verify!
        @response = @client.verify_subscription(package, product_id, token)
      end
    end
  end
end
