# frozen_string_literal: true

require 'lexis_nexis/search_service'

RSpec.describe LexisNexis::SearchService do
  include Savon::SpecHelper

  before do
    stub_const('LEXIS_NEXIS_WSDL',
               'https://bridgerstaging.lexisnexis.com/LN.WebServices/11.0/XGServices.svc?wsdl')
  end

  describe '.call' do
    context 'when searching a business entity' do
      let(:entity_type) { LexisNexis::SearchService::BUSINESS_ENTITY }
      let(:input_data) { { name: { full_name: business_name } } }
      let(:business_name) { 'Cannabis Culture' }
      let(:predefined_search_name) { 'Business Search' }

      context 'when performing a regular search' do
        it 'has records in the result' do
          response = VCR.use_cassette('successful_business_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).to be_nil
          expect(response.data.dig(:search_response, :search_result, :records)).not_to be_empty
        end
      end

      context 'when performing a no hit search' do
        let(:business_name) { 'Hooli' }

        it 'has no records in the result' do
          response = VCR.use_cassette('no_hit_business_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).to be_nil
          expect(response.data.dig(:search_response, :search_result)).not_to be_empty
          expect(response.data.dig(:search_response, :search_result, :records)).to be_nil
        end
      end

      context 'when searching with correct format but invalid input' do
        let(:business_name) { '' }

        it 'returns a result containing a watchlist match error' do
          response = VCR.use_cassette('invalid_input_business_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).to be_nil
          error = response.data.dig(
            :search_response,
            :search_result,
            :records,
            :result_record,
            :watchlist,
            :matches,
            :wl_match,
            :error
          )
          expect(error[:code]).to eq('536870950')
          expect(error[:message]).to eq('The name is empty or contains invalid data')
        end
      end

      context 'when searching with incorrectly formatted input' do
        let(:invalid_additional_info) { { additional_info: [{ something: '1234567890' }] } }

        it 'returns a deserialization error' do
          response = VCR.use_cassette('invalid_format_business_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data.merge(invalid_additional_info))
          end
          expect(response.code).not_to be_nil
          expect(response.data).to be_nil
          expect(response.errors.first[:message]).to start_with(
            'Error in deserializing body of request message for operation \'Search\'.'
          )
        end
      end
    end

    context 'when searching an individual entity' do
      let(:entity_type) { LexisNexis::SearchService::INDIVIDUAL_ENTITY }
      let(:input_data) do
        {
          name: name_fields,
          addresses: [{ country: 'United States', type: 'Current' }],
          other: { gender: 'Male' },
          additional_info: [info_fields]
        }
      end
      let(:name_fields) { { first_name: 'Donald', last_name: 'Trump', full_name: 'Donald Trump' } }
      let(:info_fields) { { type: 'DOB', value: '1946-06-14' } }
      let(:predefined_search_name) { 'Individual Search' }

      context 'when performing a regular search' do
        it 'has records in the result' do
          response = VCR.use_cassette('successful_individual_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).to be_nil
          expect(response.data[:search_response][:search_result][:records]).not_to be_empty
        end
      end

      context 'when performing a no hit search' do
        let(:name_fields) { { first_name: 'Sherlock', last_name: 'Holmes', full_name: 'Sherlock Holmes' } }

        it 'has no records in the result' do
          response = VCR.use_cassette('no_hit_individual_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).to be_nil
          expect(response.data[:search_response][:search_result]).not_to be_empty
          expect(response.data[:search_response][:search_result][:records]).to be_nil
        end
      end

      context 'when searching with correct format but invalid input' do
        let(:name_fields) { { first_name: '', last_name: '', full_name: '' } }

        it 'returns a result containing a watchlist match error' do
          response = VCR.use_cassette('invalid_input_individual_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).to be_nil
          error = response.data.dig(
            :search_response,
            :search_result,
            :records,
            :result_record,
            :watchlist,
            :matches,
            :wl_match,
            :error
          )
          expect(error[:code]).to eq('536870950')
          expect(error[:message]).to eq('The name is empty or contains invalid data')
        end
      end

      context 'when searching with incorrectly formatted input' do
        let(:info_fields) { { something: '1946-06-14' } }

        it 'returns a deserialization error' do
          response = VCR.use_cassette('invalid_format_individual_search') do
            LexisNexis::SearchService.call(predefined_search_name, entity_type, input_data)
          end
          expect(response.code).not_to be_nil
          expect(response.data).to be_nil
          expect(response.errors.first[:message]).to start_with(
            'Error in deserializing body of request message for operation \'Search\'.'
          )
        end
      end
    end
  end
end
