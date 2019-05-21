module CandyCheck
  module PlayStore
    # Configure the usage of the official Google API SDK client
    class Config < Utils::Config
      SCOPE = [
        'https://www.googleapis.com/auth/androidpublisher'
      ].freeze

      GOOGLE_ACCOUNT_TYPE = 'service_account'.freeze 

      JSON_ENV_VARS = %w[
        ANDROID_PUBLISHER_KEYFILE_JSON
        GOOGLE_CLOUD_CREDENTIALS_JSON
        GOOGLE_CLOUD_KEYFILE_JSON
        GCLOUD_KEYFILE_JSON
      ].freeze

      ENV_VARS = %w[
        GOOGLE_CLIENT_ID GOOGLE_CLIENT_EMAIL GOOGLE_PRIVATE_KEY
      ].freeze

      ATTRS = %w[
        client_id client_email private_key
      ].freeze

      ATTRS.each do |attr|
        attr_reader attr
      end

      # Initializes a new configuration from a hash
      # @param attributes [Hash]
      # @example Initialize with a hash
      #   CandyCheck::PlayStore::Config.new(
      #     client_id: '000000000000000000000',
      #     client_email: 'xxxx@xxxx.iam.gserviceaccount.com',
      #     private_key: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n'
      #   )
      #
      # or
      #
      # export GOOGLE_CLIENT_ID=000000000000000000000
      # export GOOGLE_CLIENT_EMAIL=xxxx@xxxx.iam.gserviceaccount.com
      # export GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
      #
      # or
      #
      # provide path to json keyfile to any of ENV vars:
      # ANDROID_PUBLISHER_KEYFILE_JSON
      # GOOGLE_CLOUD_CREDENTIALS_JSON
      # GOOGLE_CLOUD_KEYFILE_JSON
      # GCLOUD_KEYFILE_JSON

      def initialize(attributes = {})
        if attributes.any?
          super
          set_env_vars!
        else
          set_credentials!
        end
      end

      private

      def validate!
        validates_presence(:client_id)
        validates_presence(:client_email)
        validates_presence(:private_key)
      end

      def set_credentials!
        return if env_vars_credentials?

        set_credentials_from_keyfile
      end

      def env_vars_credentials?
        ENV_VARS.map { |var| ENV[var] }.all?
      end

      def set_credentials_from_keyfile
        json = ->(v) { JSON.parse File.read(ENV[v]) rescue nil unless ENV[v].nil? }
        keyfile = JSON_ENV_VARS.map(&json).compact.first

        raise "No keyfile found. Paths: #{JSON_ENV_VARS}" unless keyfile.is_a?(::Hash)

        set_env_vars!(keyfile)
      end

      def set_env_vars!(keyfile = nil)
        ATTRS.each do |attr|
          ENV["GOOGLE_#{attr.upcase}"] = keyfile ? keyfile[attr] : send(attr)
        end
      end
    end
  end
end
