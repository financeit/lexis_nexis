# frozen_string_literal: true

require 'lexis_nexis/business_id'

RSpec.describe LexisNexis::BusinessID do
  describe 'when a user_hash is built' do
    let(:hash_options) do
      {
        reference_code: 'PartnerSignup',
        billing_code: 'FPS',
        glb_purpose: 5,
        dl_purpose: 3,
        end_user: LexisNexis::BusinessID.enduser_hash('Test Company', '123 Fake Street', 'FL', '12345')
      }
    end
    context 'without an end user' do
      let(:user) do
        LexisNexis::BusinessID.user_hash(
          hash_options[:reference_code],
          hash_options[:billing_code],
          hash_options[:glb_purpose],
          hash_options[:dl_purpose]
        )
      end
      it { expect(user['ReferenceCode']).to eq(hash_options[:reference_code]) }
      it { expect(user['BillingCode']).to eq(hash_options[:billing_code]) }
      it { expect(user['GLBPurpose']).to eq(hash_options[:glb_purpose]) }
      it { expect(user['DLPurpose']).to eq(hash_options[:dl_purpose]) }
    end
    context 'with an end user' do
      let(:user) do
        LexisNexis::BusinessID.user_hash(
          hash_options[:reference_code],
          hash_options[:billing_code],
          hash_options[:glb_purpose],
          hash_options[:dl_purpose],
          hash_options[:end_user]
        )
      end
      it { expect(user['ReferenceCode']).to eq(hash_options[:reference_code]) }
      it { expect(user['BillingCode']).to eq(hash_options[:billing_code]) }
      it { expect(user['GLBPurpose']).to eq(hash_options[:glb_purpose]) }
      it { expect(user['DLPurpose']).to eq(hash_options[:dl_purpose]) }
      it { expect(user['EndUser']).to eq(hash_options[:end_user]) }
    end
  end

  describe '#wrap_request' do
    let(:hash_options) do
      {
        user: LexisNexis::BusinessID.user_hash(*LexisNexis::BusinessID::DEFAULT_USER_OPTIONS),
        sample_one_hash: {
          one: 'one'
        },
        sample_two_hash: {
          two: 'two'
        }
      }
    end
    context 'with no hashes' do
      let(:wrap_request) { LexisNexis::BusinessID.wrap_request }
      it { expect(wrap_request['User']).to eq(hash_options[:user]) }
      it { expect(wrap_request.keys).to eq(['User']) }
    end
    context 'with one hash' do
      let(:wrap_request) { LexisNexis::BusinessID.wrap_request(hash_options[:sample_one_hash]) }
      it { expect(wrap_request['User']).to eq(hash_options[:user]) }
      it { expect(wrap_request.keys).to eq(['User', :one]) }
    end
    context 'with two hashes' do
      let(:wrap_request) do
        LexisNexis::BusinessID.wrap_request(
          hash_options[:sample_one_hash],
          hash_options[:sample_two_hash]
        )
      end
      it { expect(wrap_request['User']).to eq(hash_options[:user]) }
      it { expect(wrap_request.keys).to eq(['User', :one, :two]) }
    end
  end

  describe 'when a search_hash is built' do
    let(:search_hash) { LexisNexis::BusinessID.search_hash(hash_options[:company_name]) }
    let(:hash_options) do
      {
        company_name: 'Test Company Name'
      }
    end
    it { expect(search_hash.keys).to eq(['SearchBy']) }
    it { expect(search_hash['SearchBy']).to eq('CompanyName' => hash_options[:company_name]) }
  end

  describe 'enduser_hash' do
    let(:enduser) do
      LexisNexis::BusinessID.enduser_hash(
        hash_options[:company_name],
        hash_options[:street_address],
        hash_options[:state],
        hash_options[:zip5]
      )
    end
    let(:hash_options) do
      {
        company_name: 'test company',
        street_address: '123 Fake St',
        state: 'FL',
        zip5: 90210
      }
    end
    it { expect(enduser['CompanyName']).to eq(hash_options[:company_name]) }
    it { expect(enduser['StreetAddress1']).to eq(hash_options[:street_address]) }
    it { expect(enduser['State']).to eq(hash_options[:state]) }
    it { expect(enduser['Zip5']).to eq(hash_options[:zip5]) }
  end

  describe 'authorized_representative_hash' do
    let(:authorized_representative) { LexisNexis::BusinessID.authorized_representative_hash(hash_options[:opts]) }
    let(:hash_options) do
      {
        opts: {
          name: LexisNexis::BusinessID.name_hash('test', 'name'),
          address: LexisNexis::BusinessID.address_hash('123 fake street', 'Nokomis', 'FL', 90210),
          age: 21,
          dob: LexisNexis::BusinessID.dob_hash(1990, 01, 01),
          ssn: 123211232,
          driver_license_number: 'M44FSA2',
          driver_license_state: 'FL',
          phone10: '9052334523',
          former_last_name: 'Namer'
        }
      }
    end
    it { expect(authorized_representative['Name']).to eq(hash_options[:opts][:name]) }
    it { expect(authorized_representative['Address']).to eq(hash_options[:opts][:address]) }
    it { expect(authorized_representative['Age']).to eq(hash_options[:opts][:age]) }
    it { expect(authorized_representative['Dob']).to eq(hash_options[:opts][:dob]) }
    it { expect(authorized_representative['Ssn']).to eq(hash_options[:opts][:ssn]) }
    it { expect(authorized_representative['DriverLicenseNumber']).to eq(hash_options[:opts][:driver_license_number]) }
    it { expect(authorized_representative['DriverLicenseState']).to eq(hash_options[:opts][:driver_license_state]) }
    it { expect(authorized_representative['Phone10']).to eq(hash_options[:opts][:phone10]) }
    it { expect(authorized_representative['FormerLastName']).to eq(hash_options[:opts][:former_last_name]) }
  end

  describe 'dob_hash' do
    let(:dob_hash) { LexisNexis::BusinessID.dob_hash(hash_options[:year], hash_options[:month], hash_options[:day]) }
    let(:hash_options) do
      {
        year: 1989,
        month: 01,
        day: 01
      }
    end
    it { expect(dob_hash['Year']).to eq(hash_options[:year]) }
    it { expect(dob_hash['Month']).to eq(hash_options[:month]) }
    it { expect(dob_hash['Day']).to eq(hash_options[:day]) }
  end

  describe 'when a name_hash is built' do
    let(:hash_options) do
      {
        first_name: 'Test',
        last_name: 'User',
        middle_name: 'W.',
        suffix: 'Jr'
      }
    end
    context 'with only a first and last name' do
      let(:name_hash) { LexisNexis::BusinessID.name_hash(hash_options[:first_name], hash_options[:last_name]) }
      it { expect(name_hash['First']).to eq(hash_options[:first_name]) }
      it { expect(name_hash['Last']).to eq(hash_options[:last_name]) }
      it { expect(name_hash.keys).to eq(%w[First Last]) }
    end

    context 'with a suffix' do
      let(:name_hash) { LexisNexis::BusinessID.name_hash(hash_options[:first_name], hash_options[:last_name], hash_options[:suffix]) }
      it { expect(name_hash['First']).to eq(hash_options[:first_name]) }
      it { expect(name_hash['Last']).to eq(hash_options[:last_name]) }
      it { expect(name_hash['Suffix']).to eq(hash_options[:suffix]) }
      it { expect(name_hash.keys).to eq(%w[First Last Suffix]) }
    end

    context 'with a suffix and middle name' do
      let(:name_hash) do
        LexisNexis::BusinessID.name_hash(
          hash_options[:first_name],
          hash_options[:last_name],
          hash_options[:suffix],
          hash_options[:middle_name]
        )
      end
      it { expect(name_hash['First']).to eq(hash_options[:first_name]) }
      it { expect(name_hash['Last']).to eq(hash_options[:last_name]) }
      it { expect(name_hash['Middle']).to eq(hash_options[:middle_name]) }
      it { expect(name_hash['Suffix']).to eq(hash_options[:suffix]) }
      it { expect(name_hash.keys).to eq(%w[First Last Suffix Middle]) }
    end
  end

  describe 'when an options_hash is built' do
    context 'with the default options' do
      let(:options_hash) { LexisNexis::BusinessID.options_hash }
      let(:hash_options) do
        {
          watchlists: %w[BES CFTC DTC EUDT FBI FCEN FAR IMW OFAC OCC OSFI PEP SDT BIS UNNT WBIF],
          ms_override: 0,
          dl_verification: 0,
          po_box: 0,
          global_watchlist: 0.84,
          business_defender: 0,
          all_risk_indicators: 0
        }
      end
      it { expect(options_hash['Watchlists'].values.first).to eq(hash_options[:watchlists]) }
      it { expect(options_hash['IncludeMSOverride']).to eq(hash_options[:ms_override]) }
      it { expect(options_hash['IncludeDLVerification']).to eq(hash_options[:dl_verification]) }
      it { expect(options_hash['PoBoxCompliance']).to eq(hash_options[:po_box]) }
      it { expect(options_hash['GlobalWatchlistThreshold']).to eq(hash_options[:global_watchlist]) }
      it { expect(options_hash['IncludeModels'].keys).to eq(['BusinessDefender']) }
      it { expect(options_hash['IncludeModels']['BusinessDefender']).to eq(hash_options[:business_defender]) }
      it { expect(options_hash['IncludeAllRiskIndicators']).to eq(hash_options[:all_risk_indicators]) }
    end

    context 'with custom options' do
      let(:options_hash) { LexisNexis::BusinessID.options_hash(hash_options) }
      let(:hash_options) do
        {
          watchlists: %w[BES],
          include_ms_override: 1,
          include_dl_verification: 0,
          po_box_compliance: 0,
          global_watchlist_threshold: 0.84,
          business_defender: 0,
          include_all_risk_indicators: 0
        }
      end
      it { expect(options_hash['Watchlists'].values.first).to eq(hash_options[:watchlists]) }
      it { expect(options_hash['IncludeMSOverride']).to eq(hash_options[:include_ms_override]) }
      it { expect(options_hash['IncludeDLVerification']).to eq(hash_options[:include_dl_verification]) }
      it { expect(options_hash['PoBoxCompliance']).to eq(hash_options[:po_box_compliance]) }
      it { expect(options_hash['GlobalWatchlistThreshold']).to eq(hash_options[:global_watchlist_threshold]) }
      it { expect(options_hash['IncludeModels'].keys).to eq(['BusinessDefender']) }
      it { expect(options_hash['IncludeModels']['BusinessDefender']).to eq(hash_options[:business_defender]) }
      it { expect(options_hash['IncludeAllRiskIndicators']).to eq(hash_options[:include_all_risk_indicators]) }
    end
  end
end
