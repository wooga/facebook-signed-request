$LOAD_PATH.unshift( File.dirname(__FILE__) )

require 'test_helper'

class SignedRequestTest < Test::Unit::TestCase

  def setup

    Facebook::SignedRequest.secret = "897a956a2f7eadcc5783a458fe3e7556"

    @valid_request      = "vl0p_bGyDeVZ2I21cJvLd5C9CwpMkU2mcp1eUGWdvWs.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTMwODk4ODgwMC4xLTEwMDAwMDY1NDM0MzE5OXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ9"
    @invalid_request_1  = "l0p_bGyDeVZ2I21cJvLd5C9CwpMkU2mcp1eUGWdvWs.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTMwODk4ODgwMC4xLTEwMDAwMDY1NDM0MzE5OXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ9"
    @invalid_request_2  = "vl0p_bGyDeVZ2I21cJvLd5C9CwpMkU2mcp1eUGWdvWs.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTMwODk4ODgwMC4xLTEwMDAwMDY1NDM0MzE5OXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ"

  end

  test "parsing a valid request" do
    request = Facebook::SignedRequest.new( @valid_request )
    assert request.valid?,        "Request should be valid"
    assert request.errors == [],  "Request should contain no errors"
  end

  test "parsing a request with invalid signature" do
    request = Facebook::SignedRequest.new( @invalid_request_1 )
    assert_equal false, request.valid?
    assert_equal 2, request.errors.length
  end

  test "parsing a request with invalid payload" do
    request = Facebook::SignedRequest.new( @invalid_request_2 )
    assert_equal false, request.valid?
    assert_equal 4, request.errors.length
  end

  test "new request with invalid secret" do
    exception = assert_raise ArgumentError do
      request = Facebook::SignedRequest.new( "foo.bar", :secret => 2 )
    end

    expected = "Secret should be a String"

    assert_equal expected, exception.message
  end

  test "new request with missing secret" do
    Facebook::SignedRequest.secret = nil

    exception = assert_raise ArgumentError do
      request = Facebook::SignedRequest.new( "foo.bar" )
    end

    expected = "No secret provided. Use SignedRequest.secret= or the options hash"

    assert_equal expected, exception.message
  end

  test "new request with invalid parameters" do
    exception = assert_raise ArgumentError do
      request = Facebook::SignedRequest.new( "foobar" )
    end

    expected = "Invalid Format. See http://developers.facebook.com/docs/authentication/signed_request/"

    assert_equal expected, exception.message
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
    request_1 = Facebook::SignedRequest.new( @valid_request )

    reencoded_request = Facebook::SignedRequest.encode_and_sign(request_1.data)

    sig_1, data_1 = @valid_request.split(".", 2)
    sig_2, data_2 = reencoded_request.split(".", 2)

    # Simulate invalid raw Base64 from Facebook by removing padding
    assert_equal sig_1, sig_2.gsub(/=+$/, "")
    assert_equal data_1, data_2.gsub(/=+$/, "")

    request_2 = Facebook::SignedRequest.new( reencoded_request )

    assert_equal request_1.signature, request_2.signature
    assert_equal request_1.data,      request_2.data
  end

end
