$LOAD_PATH.unshift( File.dirname(__FILE__) )

require 'test_helper'

class SignedRequestTest < Test::Unit::TestCase

  def setup

    Facebook::SignedRequest.secret = "897z956a2z7zzzzz5783z458zz3z7556"

    @valid_request      = "53umfudisP7mKhsi9nZboBg15yMZKhfQAARL9UoZtSE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9"
    @invalid_request_1  = "umfudisP7mKhsi9nZboBg15yMZKhfQAARL9UoZtSE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9"
    @invalid_request_2  = "53umfudisP7mKhsi9nZboBg15yMZKhfQAARL9UoZtSE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ"

  end

  test "parsing a valid request" do
    request = Facebook::SignedRequest.new( @valid_request )
    assert request.valid?,        "Request should be valid"
    assert request.errors == [],  "Request should contain no errors"
  end

  test "data of valid request is parsed to ruby hash with symbols as keys" do
    request = Facebook::SignedRequest.new( @valid_request )

    key_classes = request.data.map { |k,v| k.class } | [Symbol]

    assert_equal 1, key_classes.length, "All keys should be symbols"
  end

  test "parsing a request with invalid signature" do
    request = Facebook::SignedRequest.new( @invalid_request_1 )
    assert_equal false, request.valid?
    assert_equal 1, request.errors.length
  end

  test "parsing a request with invalid payload" do
    request = Facebook::SignedRequest.new( @invalid_request_2 )
    assert_equal false, request.valid?
    assert_equal 3, request.errors.length
  end

  test "new request with invalid secret" do
    request = Facebook::SignedRequest.new( "foo.bar", :secret => 2 )
    assert request.invalid?
  end

  test "new request with missing secret" do
    Facebook::SignedRequest.secret = nil
    request = Facebook::SignedRequest.new( "foo.bar" )
    assert request.invalid?
  end

  test "new request with invalid parameters" do
    request = Facebook::SignedRequest.new( "foobar" )
    assert request.invalid?
  end

  test "request with :strict => true fails for expired oauth token" do
    exception = assert_raise ArgumentError do
      request = Facebook::SignedRequest.new( @valid_request, :strict => true )
    end


    assert(
      exception.message.match("OAuth Token has expired"),
      "Wrong Exception message"
    )
  end

  test "encode and sign request params" do

    request_params = {
      :expires      => 1308988800,
      :algorithm    => "HMAC-SHA256",
      :user_id      => "111111111111111",
      :oauth_token  => "111111111111111|2.AQBAttR11|T49w3BqoZUegypru1Gra70hED8",
      :user         => {
        :country  => "de",
        :locale   => "en_US",
        :age      => { :min => 21 }
      },
      :issued_at    => 1308985018
    }

    request_json = request_params.to_json
    encoded_json = Base64.urlsafe_encode64( request_json )

    reencoded_request = Facebook::SignedRequest.encode_and_sign( request_params )

    signature, payload = reencoded_request.split(".", 2)

    assert_equal encoded_json, payload

    new_request = Facebook::SignedRequest.new( reencoded_request )

    assert_equal new_request.data, request_params
  end

  test "ring encoding request with invalid base64 signature and payload" do

    fake = {"algorithm"=>"HMAC-SHA256", "expires"=>1309186800, "issued_at"=>1309183033, "oauth_token"=>"111111111111111|2.AQDpIv3FOWbnCv8z.3600.1111111100.1-1111100000|0vSxxsZC1R_I6fb_Jw2I8WEXztE", "user"=>{"country"=>"en", "locale"=>"en_US", "age"=>{"min"=>21}}, "user_id"=>"1111100000"}

    Facebook::SignedRequest.secret = "11ce1114e5450047acb7764c64c6ca24"

    request_string    = Facebook::SignedRequest.encode_and_sign( fake )
    req_sig, req_data = request_string.split(".", 2)

    assert req_sig  !~ /\=$/
    assert req_data !~ /\=$/

    request = Facebook::SignedRequest.new( request_string )

    assert Base64.urlsafe_encode64( request.signature ) =~ /\=$/
    assert request.encoded_data =~ /\=$/

  end

end
