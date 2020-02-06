# frozen_string_literal: true

module LexisNexis
  # Helper for SearchAttributes to build input classes
  module SearchHelper
    def get_addresses_hash(addresses)
      return addresses if addresses.nil? || addresses.empty?

      addresses.map do |address|
        {
          InputAddress: {
            City: address.dig(:city),
            Country: address.dig(:country),
            FullAddress: address.dig(:address),
            Street1: address.dig(:address),
            Street2: address.dig(:address_2),
            PostalCode: address.dig(:postal_code),
            State: address.dig(:state),
            Type: 'Current', # Required if address present
          }.compact
        }
      end
    end

    def get_object_hash_list(object_name, objects)
      return objects if objects.nil? || objects.empty?

      objects.map do |object|
        object_attributes = {
          Number: object.dig(:value),
          Type: object.dig(:type) # Required if object present
        }
        Hash[object_name, object_attributes]
      end
    end
  end
end
