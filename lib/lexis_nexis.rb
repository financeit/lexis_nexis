# frozen_string_literal: true

require 'savon'
require 'lexis_nexis/response'

# LexisNexis class connects to client with WSDL, sends requests, and handles responses
# Default endpoint is Search
module LexisNexis
  DEFAULT_CLIENT_HASH = {
    env_namespace: :soap,
    element_form_default: :qualified,
    pretty_print_xml: true,
    namespace_identifier: :brid,
    convert_request_keys_to: :none
  }
  RESPONSE_DELIMITER = "_response"
  RESULT_DELIMITER = "_result"
  RESPONSE_INDEX = "XML"
  DEFAULT_ERROR_MESSAGE = "Error in Response"
  KEYERROR_MESSAGE = "Malformed response object"

  def self.client(wsdl, endpoint: 'Search', log: false)
    config = DEFAULT_CLIENT_HASH
    config[:wsdl] = wsdl
    config[:log] = log
    config[:endpoint] = wsdl.sub('?wsdl', "/#{endpoint}").to_s
    Savon::Client.new(config)
  end

  def self.credentials_hash
    {
      ClientID: LEXIS_NEXIS_CLIENT_ID,
      Password: LEXIS_NEXIS_PASSWORD,
      UserID: LEXIS_NEXIS_USERNAME
    }
  end

  def self.send_request(client_obj, operation, hash)
    results = client_obj.call(operation, message: hash)
    LexisNexis::Response.success(results.body)
  rescue Savon::SOAPFault => e
    error_hash = e.to_hash
    report_error(error_hash[:fault][:faultcode], error_hash[:fault][:detail][:service_fault])
  rescue Savon::HTTPError => e
    error_hash = e.to_hash
    LexisNexis::Response.error(error_hash.code, error_hash.body)
  end

  def self.report_error(fault_code, errors)
    # We may receive one or more exceptions. log all of them just incase
    errors = errors.is_a?(Array) ? errors : [errors]
    codes = []
    errors.each { |error| codes.push(error_code(error[:message])) }
    LexisNexis::Response.error(codes.first || fault_code, errors)
  end

  def self.error_code(message)
    /\[([a-zA-Z\d:_]+)\]/.match(message)&.captures&.first
  end
end
