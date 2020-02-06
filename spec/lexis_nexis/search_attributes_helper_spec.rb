# frozen_string_literal: true

require 'lexis_nexis/search_attributes_helper'

RSpec.describe LexisNexis::SearchAttributesHelper do
  describe '#get_addresses_hash' do
    let(:get_addresses_hash) { LexisNexis::SearchAttributesHelper.get_addresses_hash(addresses) }

    context 'when input is nil' do
      let(:addresses) { nil }

      it 'returns nil' do
        expect(get_addresses_hash).to be_nil
      end
    end

    context 'when input is an empty list' do
      let(:addresses) { [] }

      it 'returns an empty list' do
        expect(get_addresses_hash).to eq([])
      end
    end

    context 'when input has one address' do
      let(:addresses) { [input_object] }
      let(:input_object) do
        {
          city: 'Toronto',
          country: 'Canada',
          postal_code: '123456',
          address: '123 Sesame Street',
          state: nil,
          type: 'Current'
        }
      end
      let(:expected_object) do
        {
          InputAddress: {
            City: 'Toronto',
            Country: 'Canada',
            FullAddress: '123 Sesame Street',
            PostalCode: '123456',
            Street1: '123 Sesame Street',
            Type: 'Current'
          }
        }
      end

      it 'returns a valid InputAddress class' do
        expect(get_addresses_hash).to eq([expected_object])
      end
    end

    context 'when input has multiple addresses' do
      let(:addresses) { [input_object, input_object] }
      let(:input_object) do
        {
          city: 'Toronto',
          country: 'Canada',
          postal_code: '123456',
          address: '123 Sesame Street',
          state: nil,
          type: 'Current'
        }
      end
      let(:expected_object) do
        {
          InputAddress: {
            City: 'Toronto',
            Country: 'Canada',
            FullAddress: '123 Sesame Street',
            PostalCode: '123456',
            Street1: '123 Sesame Street',
            Type: 'Current'
          }
        }
      end

      it 'returns valid InputAddress classes' do
        expect(get_addresses_hash).to eq([expected_object, expected_object])
      end
    end

    context 'when input is missing type' do
      let(:addresses) { [input_object] }
      let(:input_object) do
        {
          city: 'Toronto',
          country: 'Canada',
          postal_code: '123456',
          address: '123 Sesame Street',
        }
      end
      let(:expected_object) do
        {
          InputAddress: {
            City: 'Toronto',
            Country: 'Canada',
            FullAddress: '123 Sesame Street',
            PostalCode: '123456',
            Street1: '123 Sesame Street',
            Type: 'Unknown'
          }
        }
      end

      it 'defaults to \'Unknown\'' do
        expect(get_addresses_hash).to eq([expected_object])
      end
    end

    context 'when input has an invalid type' do
      let(:addresses) { [input_object] }
      let(:input_object) do
        {
          city: 'Toronto',
          country: 'Canada',
          postal_code: '123456',
          address: '123 Sesame Street',
          type: 'Something invalid'
        }
      end

      it 'raises an error' do
        expect { get_addresses_hash }.to raise_error(TypeError)
      end
    end
  end

  describe '#get_object_hash_list' do
    let(:get_objects_hash) { LexisNexis::SearchAttributesHelper.get_object_hash_list(:InputId, objects) }

    context 'when input is nil' do
      let(:objects) { nil }

      it 'returns nil' do
        expect(get_objects_hash).to be_nil
      end
    end

    context 'when input is an empty list' do
      let(:objects) { [] }

      it 'returns an empty list' do
        expect(get_objects_hash).to eq([])
      end
    end

    context 'when input has one object' do
      let(:objects) { [input_object] }
      let(:input_object) do
        {
          value: 'Value',
          type: 'EIN'
        }
      end
      let(:expected_object) do
        {
          InputId: {
            Number: 'Value',
            Type: 'EIN'
          }
        }
      end

      it 'returns a valid class' do
        expect(get_objects_hash).to eq([expected_object])
      end
    end

    context 'when input has multiple objects' do
      let(:objects) { [input_object, input_object] }
      let(:input_object) do
        {
          value: 'Value',
          type: 'VISA'
        }
      end
      let(:expected_object) do
        {
          InputId: {
            Number: 'Value',
            Type: 'VISA'
          }
        }
      end

      it 'returns valid classes' do
        expect(get_objects_hash).to eq([expected_object, expected_object])
      end
    end

    context 'when input is missing type' do
      let(:objects) { [input_object] }
      let(:input_object) do
        {
          value: 'Value'
        }
      end
      let(:expected_object) do
        {
          InputId: {
            Number: 'Value',
            Type: 'Other'
          }
        }
      end

      it 'defaults to the catch all type for that class' do
        expect(get_objects_hash).to eq([expected_object])
      end
    end

    context 'when input has an invalid type' do
      let(:objects) { [input_object] }
      let(:input_object) do
        {
          value: 'Value',
          type: 'Type'
        }
      end

      it 'raises an error' do
        expect { get_objects_hash }.to raise_error(TypeError)
      end
    end
  end
end
