$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'facebook-signed-request'))

require 'rubygems'
require 'facebook-signed-request/version'
require 'openssl'
require 'base64'
require 'base64_backport' if RUBY_VERSION < "1.9.0"
require 'json'
require 'signed_request'

module Facebook



end
