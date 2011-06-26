module Facebook
  class SignedRequest
    attr_reader :errors, :signature, :data

    def initialize( request_data, secret )
      @encoded_signature, @encoded_data = request_data.split(".", 2)

      if @encoded_signature.nil? || @encoded_data.nil?
        raise ArgumentError, "Invalid Format. See http://developers.facebook.com/docs/authentication/signed_request/"
      end

      @errors           = []
      @secret           = secret

      @signature        = extract_request_signature
      @payload          = extract_request_payload
      @data             = parse_request_playload

      validate_algorithm
      validate_signature
    end


    def extract_request_signature
      begin
        return base64_url_decode(@encoded_signature).unpack('H*')[0]
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
        return JSON.parse( @payload )
      rescue
        @errors << "Invalid JSON object"
        return nil
      end
    end

    def validate_algorithm
      if @data.nil? || @data['algorithm'] != "HMAC-SHA256"
        @errors << "Invalid Algorithm. Expected: HMAC-SHA256"
      end
    end

    def validate_signature
      digestor = Digest::HMAC.new( @secret, Digest::SHA256 )
      computed_signature = digestor.hexdigest( @encoded_data )

      if @signature != computed_signature
        message = "Signatures do not match. " \
                  "Computed: #{computed_signature} but was #{@signature.inspect}"

        @errors << message
      end
    end

    def base64_url_decode( encoded_string )
      encoded_string << '=' until ( encoded_string.length % 4 == 0 )
      Base64.strict_decode64(encoded_string.gsub("-", "+").gsub("_", "/"))
    end

    def valid?
      @errors.empty?
    end

  end
end
