# frozen_string_literal: true

require 'lexis_nexis'

module LexisNexis
  # Class to handle calls to search for an entity
  class SearchService
    include LexisNexis

    PREDEFINED_SEARCH_NAME = 'Borrower Onboarding'
    INDIVIDUAL_ENTITY = 'Individual'
    BUSINESS_ENTITY = 'Business'
    SEARCH_OPERATION = :search
    SEARCH_PARAMETERS = {
      context: LexisNexis.credentials_hash,
      config: { PredefinedSearchName: PREDEFINED_SEARCH_NAME }
    }

    def self.call!(entity_type, input_data)
      LexisNexis.send_request(
        LexisNexis.client(LEXIS_NEXIS_WSDL),
        SEARCH_OPERATION,
        SEARCH_PARAMETERS.merge(LexisNexis::SearchAttributes.format_input(entity_type, input_data))
      )
    end
  end
end
