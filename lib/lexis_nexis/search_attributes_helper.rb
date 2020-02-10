# frozen_string_literal: true

module LexisNexis
  # Module to build search attributes for LexisNexis search operation input
  module SearchAttributesHelper
    VALID_ADDRESS_TYPES = %w[Current Mailing Previous Unknown].freeze
    VALID_PHONE_TYPES = %w[Business Cell Fax Home Work Unknown].freeze
    VALID_ID_TYPES = %w[ABARouting Account AlienRegistration BankIdentifierCode BankPartyID Cedula ChipsUID
                        CustomerNumber DriversLicense DUNS EFTCode EIN GLN IBAN IBEI MedicareID
                        MedicareReference Member Military National NIT Other Passport ProprietaryUID
                        ProviderID RTACardNumber SSN SwiftBEI SwiftBIC TaxID VISA].freeze
    VALID_ADDITIONAL_INFO_TYPES = %w[Citizenship Complexion DistinguishingMarks DOB EyeColor HairColor
                                     Height Incident IPAddress MothersName Nationality Occupation Other
                                     PlaceOfBirth Position Race VesselCallSign VesselFlag VesselGRT
                                     VesselOwner VesselTonnage VesselType Weight].freeze
    CATCH_ALL_TYPES = {
      InputPhone: 'Unknown',
      InputId: 'Other'
    }.freeze

    def self.format_input(entity_type, data)
      {
        input: {
          Records: {
            InputRecord: {
              Entity: {
                EntityType: entity_type,
                Name: {
                  First: data.dig(:name, :first_name),
                  Last: data.dig(:name, :last_name),
                  Full: data.dig(:name, :full_name),
                  Middle: data.dig(:name, :middle_name)
                }.compact,
                Addresses: get_addresses_hash(data.dig(:addresses)),
                IDs: get_object_hash_list(:InputId, data.dig(:ids)),
                Phones: get_object_hash_list(:InputPhone, data.dig(:phones)),
                Gender: data.dig(:other, :gender),
                AdditionalInfo: get_object_hash_list(:InputAdditionalInfo, data.dig(:additional_info))
              }.compact
            }
          }
        }
      }
    end

    def self.get_addresses_hash(addresses)
      return addresses if addresses.nil? || addresses.empty?

      addresses.map do |address|
        validate_object(:InputAddress, address)

        {
          InputAddress: {
            City: address.dig(:city),
            Country: address.dig(:country),
            FullAddress: address.dig(:address),
            Street1: address.dig(:address),
            Street2: address.dig(:address_2),
            PostalCode: address.dig(:postal_code),
            State: address.dig(:state),
            Type: address.dig(:type) || 'Unknown'
          }.compact
        }
      end
    end

    def self.get_object_hash_list(object_name, objects)
      return objects if objects.nil? || objects.empty?

      objects.map do |object|
        validate_object(object_name, object)

        object_attributes = {
          Number: object.dig(:value),
          Type: object.dig(:type) || CATCH_ALL_TYPES[object_name]
        }
        Hash[object_name, object_attributes]
      end
    end

    def self.validate_object(object_name, object)
      return if object.dig(:type).nil?

      type_list = case object_name
                  when :InputAddress
                    VALID_ADDRESS_TYPES
                  when :InputId
                    VALID_ID_TYPES
                  when :InputPhone
                    VALID_PHONE_TYPES
                  when :InputAdditionalInfo
                    VALID_ADDITIONAL_INFO_TYPES
                  end

      unless type_list.include?(object.dig(:type))
        raise(TypeError, "#{object_name} Type value #{object.dig(:type)} invalid. " \
              "Type must be one of #{type_list}.")
      end
    end
  end
end
