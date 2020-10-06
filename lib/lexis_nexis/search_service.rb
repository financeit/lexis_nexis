# frozen_string_literal: true

require 'lexis_nexis'
require 'lexis_nexis/search_attributes_helper'

module LexisNexis
  # Class to handle calls to search for an entity
  class SearchService
    include LexisNexis

    INDIVIDUAL_ENTITY = 'Individual'
    BUSINESS_ENTITY = 'Business'
    SEARCH_OPERATION = :search
    SEARCH_PARAMETERS = {
      context: LexisNexis.credentials_hash
    }

    def self.call(predefined_search_name, entity_type, input_data)
      search_parameters = SEARCH_PARAMETERS
                            .merge(config: { PredefinedSearchName: predefined_search_name })
                            .merge(LexisNexis::SearchAttributesHelper.format_input(entity_type, input_data))

      LexisNexis.send_request(
        LexisNexis.client(LEXIS_NEXIS_WSDL),
        SEARCH_OPERATION,
        search_parameters
      )
    end
  end
end
