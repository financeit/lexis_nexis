# Copied from financeit/lib/service_response.rb
# frozen_string_literal: true

module LexisNexis
  module Response
    # Creates a success ResponseObject instance
    # Params:
    # +data+:: +hash+ optional data for the success response
    def self.success(data = {})
      ResponseObject.new(data)
    end

    # Creates an error ResponseObject instance
    # Params:
    # +code+:: +int+ error code to send back. Typically 500
    # +errors+:: +object+ object that contains atleast one error (defaults to empty hash)
    def self.error(code, errors = {})
      ResponseObject.new(errors, code)
    end

    #Object class for success/error responses
    class ResponseObject
      attr_reader :code, :data, :errors
      # Creates either a succes or error ResponseObject instance
      # Params:
      # +data+:: +hash+ Will contain success/error data
      # +code+:: +int+ error code for error object
      def initialize(data = {}, code = nil)
        @code = code
        @data = nil
        @errors = nil
        if @code
          @errors = data
        else
          @data = data
        end
      end
      # Checks for a successful ResponseObject
      def success?
        @code.blank?
      end

      # converts our response object to a hash
      def to_hash
        if success?
          @data
        else
          {
            code: @code,
            errors: @errors
          }
        end
      end
    end
  end
end
