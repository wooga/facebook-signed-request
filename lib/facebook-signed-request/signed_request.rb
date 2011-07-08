module Facebook
  class SignedRequest

    class << self
      attr_accessor :secret

      # Creates a signed_request with correctly padded Base64 encoding.
      # Mostly useful for testing.
      def encode_and_sign options
        encoded_data      = Base64.urlsafe_encode64( options.to_json ).tr('=', '')
        digestor          = OpenSSL::Digest::Digest.new('sha256')
        signature         = OpenSSL::HMAC.digest( digestor, @secret, encoded_data )
        encoded_signature = Base64.urlsafe_encode64( signature )
        encoded_signature = encoded_signature.tr('=', '')

        "#{encoded_signature}.#{encoded_data}"
      end
    end

    attr_reader :errors, :signature, :data, :encoded_data

    def initialize( request_data, options = {} )
      if request_data.respond_to?(:split)
        @encoded_signature, @encoded_data = request_data.split(".", 2)
      else
        @encoded_signature, @encoded_data = nil
      end

      @secret = options[:secret] || SignedRequest.secret
      @errors = []

      check_for_invalid_arguments

      @signature          = extract_request_signature
      @computed_signature = compute_signature
      @payload            = extract_request_payload
      @data               = parse_request_playload

      validate_algorithm
      validate_signature
      validate_timestamp if options[:strict] == true
    end

    def valid?
      @errors.empty?
    end

    def invalid?
      !valid?
    end

    private

    def check_for_invalid_arguments
      if @encoded_signature.nil? || @encoded_data.nil?
        @errors << "Invalid Format. See http://developers.facebook.com/docs/authentication/signed_request/"
      end

      if @secret.nil?
        @errors << "No secret provided. Use SignedRequest.secret= or the options hash"
      end

      unless @secret.is_a?( String )
        @errors << "Secret should be a String"
      end
    end

    def base64_url_decode( encoded_string )
      encoded_string << '=' until ( encoded_string.length % 4 == 0 )
      Base64.urlsafe_decode64(encoded_string)
    rescue
      nil
    end

    def extract_request_signature
      begin
        return base64_url_decode(@encoded_signature)
      rescue ArgumentError
        @errors << "Invalid Base64 encoding for signature"
        return nil
      end
    end

    def extract_request_payload
      begin
        base64_url_decode(@encoded_data)
      rescue ArgumentError
        @errors << "Invalid Base64 Encoding for data"
        return nil
      end
    end

    def parse_request_playload
      begin
        return JSON.parse( @payload, :symbolize_names => true )
      rescue
        @errors << "Invalid JSON object"
        return {}
      end
    end

    def validate_algorithm
      if @data[:algorithm] != "HMAC-SHA256"
        @errors << "Invalid Algorithm. Expected: HMAC-SHA256"
      end
    end

    def compute_signature
      digestor            = OpenSSL::Digest::Digest.new('sha256')
      computed_signature  = OpenSSL::HMAC.digest(
        digestor, @secret, @encoded_data
      )
    rescue
      nil
    end

    def validate_signature
      if @signature != @computed_signature
        message = "Signatures do not match. " \
                  "Computed: #{@computed_signature} but was #{@signature}"

        @errors << message
      end
    end

    def validate_timestamp
      timestamp = @data[:expires]

      if timestamp && Time.at( timestamp ) <= Time.now
        raise ArgumentError, "OAuth Token has expired: #{Time.at( timestamp )}"
      end
    end

    def urlsafe_encode64
      strict_encode64(bin).tr("+/", "-_")
    end

    def urlsafe_decode64
      Base64.strict_decode64(str.tr("-_", "+/"))
    end

  end
end
