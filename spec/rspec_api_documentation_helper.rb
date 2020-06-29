RspecApiDocumentation.configure do |config|
  REQUEST_HEADERS = %w[Accept Content-Type X-Auth-Token].freeze
  RESPONSE_HEADERS = %w[].freeze

  config.format = :json
  config.request_body_formatter = :json
  config.response_headers_to_include = RESPONSE_HEADERS
  config.request_headers_to_include = REQUEST_HEADERS
  config.curl_headers_to_filter = %w[Host Cookie]
  config.curl_host = 'http://api.example.com'
end
