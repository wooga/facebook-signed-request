$LOAD_PATH.unshift( File.dirname(__FILE__) )

require 'test_helper'

class SignedRequestTest < Test::Unit::TestCase

  def setup

    Facebook::SignedRequest.secret = "897a956a2f7eadcc5783a458fe3e7556"

    @valid_request      = "vl0p_bGyDeVZ2I21cJvLd5C9CwpMkU2mcp1eUGWdvWs.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTMwODk4ODgwMC4xLTEwMDAwMDY1NDM0MzE5OXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ9"
    @invalid_request_1  = "l0p_bGyDeVZ2I21cJvLd5C9CwpMkU2mcp1eUGWdvWs.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTMwODk4ODgwMC4xLTEwMDAwMDY1NDM0MzE5OXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ9"
    @invalid_request_2  = "vl0p_bGyDeVZ2I21cJvLd5C9CwpMkU2mcp1eUGWdvWs.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTMwODk4ODgwMC4xLTEwMDAwMDY1NDM0MzE5OXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ"

    @foo = "Wkq_aQu7mLjm54kOMTXoQrfa-q0_FyHcwFIBeLXNMas.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDkwODYwMDAsImlzc3VlZF9hdCI6MTMwOTA4MDg3MCwib2F1dGhfdG9rZW4iOiIxMTQ5NTIyOTg1OTM4MTN8Mi5BUUJCSXVhZlhlek5xdlR2LjM2MDAuMTMwOTA4NjAwMC4xLTEwMDAwMDY1NDM0MzE5OXxGN3RGZkQ4U2tkRmgydE9tMDAwOG5fRVBJcVkiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDY1NDM0MzE5OSJ9"
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

end
