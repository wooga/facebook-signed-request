Usage
=====


```ruby
require 'facebook-signed-request'
request = Facebook::SignedRequest.new( params[:signed_request], secret )

request.valid?
# => true / false

request.errors
# => [
#  "Invalid Format. See http://developers.facebook.com/docs/authentication/signed_request/",
#  "Invalid Base64 encoding for signature",
#  "Invalid Base64 Encoding for data",
#  "Invalid JSON object",
#  "Invalid Algorithm. Expected: HMAC-SHA256",
#  "Signatures do not match. #{expected} but was #{computed}"
#]

request.data
# => {
#      "algorithm"=>"HMAC-SHA256",
#      "expires"=>1308988800,
#      "issued_at"=>1308985018,
#      "oauth_token"=>"114998258593813|2.AQBAttRlLVnwqNPZ.3600.1308988800…",
#      "user"=> {
#        "country"=>"de",
#        "locale"=>"en_US",
#        "age"=>{"min"=>21}
#      },
#      "user_id"=>"100000656666199"
#    }
```
