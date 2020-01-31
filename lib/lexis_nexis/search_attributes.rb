# frozen_string_literal: true

require 'lexis_nexis/search_helper'

module LexisNexis
  module SearchAttributes
    class << self
      include LexisNexis::SearchHelper
    end

    def self.format_input(entity_type, data)
      {
        input: {
          Records: {
            InputRecord: {
              Entity: {
                EntityType: entity_type,
                Name: {
                  First: data.dig(:name, :first_name), # Required for individual
                  Last: data.dig(:name, :last_name), # Required for individual
                  Full: data.dig(:name, :full_name), # Required for business
                  Middle: data.dig(:name, :middle_name)
                }.compact,
                Addresses: get_addresses_hash(data.dig(:addresses)), # Both
                IDs: get_object_hash_list(:InputId, data.dig(:ids)), # Might just be for business
                Phones: get_object_hash_list(:InputPhone, data.dig(:phones)), # Both
                Gender: data.dig(:other, :gender), # Only for individual
                AdditionalInfo: get_object_hash_list(:InputAdditionalInfo, data.dig(:additional_info)) # Only for individual
              }.compact
            }
          }
        }
      }
    end
  end
end
