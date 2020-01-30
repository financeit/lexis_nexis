# frozen_string_literal: true

require 'savon'
require 'lexis_nexis/response'

module LexisNexis
  DEFAULT_CLIENT_HASH = {
    env_namespace: :soap,
    element_form_default: :unqualified,
    pretty_print_xml: true
  }
  SOAP_ATTRIBUTES = { "xmlns" => "https://wsonline.seisint.com/WsIdentity" }
  RESPONSE_DELIMITER = "_response"
  RESULT_DELIMITER = "_result"
  RESPONSE_INDEX = "XML"
  DEFAULT_ERROR_MESSAGE = "Error in Response"
  KEYERROR_MESSAGE = "Malformed response object"
  PARSE_HEADERS = {
    :business_instant_id => :business_instant_id_response_ex
  }
  def self.client(wsdl, log = false)
    config = DEFAULT_CLIENT_HASH
    config[:wsdl] = wsdl
    config[:log] = log
    Savon::Client.new(config)
  end

  def self.user(refernece_code, billing_code, query_id)
    {
      "ReferenceCode" => reference_code,
      "BillingCode" => billing_code,
      "QueryId" => query_id
    }
  end

  def self.send_request(client_obj, operation, hash)
    results = client_obj.call(operation, message: hash, :attributes => SOAP_ATTRIBUTES)
    response_body_index = PARSE_HEADERS[operation]
    if !response_body_index.nil? && !results.body.nil? && !results.body[response_body_index].nil?
      response_body = results.body[response_body_index][:response][:result]
    else
      response_body = results.body
    end
    LexisNexis::Response.success(response_body)
  rescue Savon::SOAPFault => error
    error_hash = error.to_hash
    report_error(operation, error_hash[:fault][:faultcode], error_hash[:fault][:detail][:exceptions][:exception])
  rescue Savon::HTTPError => error
    error_hash = error.to_hash
    LexisNexis::Response.error(error_hash.code, error_hash.body)
  end

  def self.report_error(operation, fault_code, errors)
    #we may receive one or more exceptions. log all of them just incase
    errors = errors.is_a?(Array) ? errors : [errors]
    codes = []
    errors.each do |error|
      error_string = "LexisNexis::#{operation.to_s.upcase} failed with error `#{error[:message]}`"
      code = error_code(error[:message])
      codes.push(code)
    end
    LexisNexis::Response.error(codes.first || fault_code, errors)
  end

  def self.error_code(message)
    /\[(\d*)\]/.match(message)&.captures&.first
  end
end
