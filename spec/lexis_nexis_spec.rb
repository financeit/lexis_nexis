RSpec.describe LexisNexis do
  include Savon::SpecHelper

  before do
    stub_const('LEXIS_NEXIS_WSDL', 'https://bridgerstaging.lexisnexis.com/LN.WebServices/11.0/XGServices.svc?wsdl')
  end

  let(:error_code) { LexisNexis.error_code(error_message) }
  let(:lexis_nexis_client) { LexisNexis.client(LEXIS_NEXIS_WSDL, false) }
  let(:lexis_nexis_client_operations) { VCR.use_cassette('lexis_nexis_operations') { lexis_nexis_client.operations } }

  it 'has a version number' do
    expect(LexisNexis::VERSION).not_to be nil
  end

  describe '#client' do
    let(:operations_list) do
      [
        :change_password, :get_days_until_password_expires, :add_list,
        :delete_list, :get_list, :index_list, :merge_duplicates, :search_lists,
        :update_list, :add_result_record, :add_records, :delete_records,
        :get_records, :search_list_records, :update_record, :add_attachment,
        :delete_attachment, :get_attachment, :delete_result_records,
        :get_result_records, :search_result_records, :set_record_state,
        :delete_runs, :get_run_info, :search_runs, :get_data_file_list, :search
      ]
    end

    it 'has the correct operations list' do
      expect(lexis_nexis_client_operations).to eq(operations_list)
    end
  end

  describe '#error_code' do
    context 'with valid error code string' do
      let(:error_message) do
        '[203] Too many subjects found; please use city, state, DOB or age range to narrow your search'
      end

      it { expect(error_code).to eq('203') }
    end

    context 'with invalid error code string' do
      let(:error_message) do
        '203 Too many subjects found; please use city, state, DOB or age range to narrow your search'
      end

      it { expect(error_code).to be_nil }
    end

    context 'with no error code string' do
      let(:error_message) { nil }

      it { expect(error_code).to be_nil }
    end
  end

  describe 'When reporting an error' do
    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }

    let(:message_body) { '' }
    let(:send_request) do
      message = { code: 500, headers: {}, body: message_body}
      savon.expects(:search).with(message: {}).returns(message)
      VCR.use_cassette('lexis_nexis_request') do
        LexisNexis.send_request(lexis_nexis_client, :search, {})
      end
    end

    context 'with 1 soapfault exception our response object' do
      let(:message_body) do
        '<Envelope><Body><Fault><faultcode>500</faultcode><faultstring>[500: [203] Too many subjects found; please use city, state, DOB or age range to narrow your search]</faultstring> <faultactor>Esp</faultactor><detail><Exceptions> <Source>Esp</Source> <Exception><Code>500</Code><Audience>user</Audience><Message>[203] Too many subjects found; please use city, state,DOB or age range to narrow your search</Message> </Exception></Exceptions></detail></Fault></Body></Envelope>'
      end

      it { expect(send_request.success?).to eq(false) }
      it { expect(send_request.errors).not_to be_empty }
      it { expect(send_request.code).to eq('203') }
    end

    context 'with multiple soapfault exception our response object' do
      let(:message_body) do
        '<Envelope><Body><Fault><faultcode>500</faultcode><faultstring>[500: [204] Too many subjects found; please use city, state, DOB or age range to narrow your search]</faultstring> <faultactor>Esp</faultactor><detail><Exceptions> <Source>Esp</Source> <Exception><Code>500</Code><Audience>user</Audience><Message>[204] Too many subjects found; please use city, state,DOB or age range to narrow your search</Message> </Exception><Source>Esp</Source> <Exception><Code>500</Code><Audience>user</Audience><Message>[203] Too many subjects found; please use city, state,DOB or age range to narrow your search</Message> </Exception></Exceptions></detail></Fault></Body></Envelope>'
      end

      it { expect(send_request.success?).to eq(false) }
      it { expect(send_request.errors).not_to be_empty }
      it { expect(send_request.code).to eq('204') }
    end
  end

  describe 'When reporting a successful call' do
    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }

    let(:message_body) { '<Envelope><Body><Input>Test</Input></Body></Envelope>' }
    let(:send_request) do
      message = { code: 200, headers: {}, body: message_body}
      savon.expects(:search).with(message: {}).returns(message)
      VCR.use_cassette('lexis_nexis_request') do
        LexisNexis.send_request(lexis_nexis_client, :search, {})
      end
    end

    context 'with response body' do
      it { expect(send_request.success?).to eq(true) }
      it { expect(send_request.errors).to be_nil }
      it { expect(send_request.code).to be_nil }
      it { expect(send_request.data).not_to be_nil }
      it { expect(send_request.data).to eq({ input: "Test" }) }
    end
  end
end
