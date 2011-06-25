## Usage

```ruby
require 'facebook-signed-request'
request = Facebook::SignedRequest.new( params[:signed_request], secret )

request.valid?
# => true / false

request.errors
# => [
  "Invalid Format. See http://developers.facebook.com/docs/authentication/signed_request/",
  "Invalid Base64 encoding for signature",
  "Invalid Base64 Encoding for data",
  "Invalid JSON object",
  "Invalid Algorithm. Expected: HMAC-SHA256",
  "Signature do not match. #{expected} but was #{computed}"
]
```
