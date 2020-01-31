# frozen_string_literal: true

RSpec.describe LexisNexis do
  include Savon::SpecHelper

  before do
    stub_const('LEXIS_NEXIS_WSDL', 'https://bridgerstaging.lexisnexis.com/LN.WebServices/11.0/XGServices.svc?wsdl')
  end

  let(:lexis_nexis_client) { VCR.use_cassette('client_connection') { LexisNexis.client(LEXIS_NEXIS_WSDL) } }
  let(:lexis_nexis_client_operations) { VCR.use_cassette('operations_list') { lexis_nexis_client.operations } }

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
    let(:error_code) { LexisNexis.error_code(error_message) }

    context 'with valid error code string' do
      let(:error_message) do
        '[a:ServiceFaultFault] The following error occurred while processing your request. ' \
        'Please contact your system administrator. Type is required in InputPhone tag'
      end

      it { expect(error_code).to eq('a:ServiceFaultFault') }
    end

    context 'with invalid error code string' do
      let(:error_message) do
        'a:ServiceFaultFault The following error occurred while processing your request. ' \
        'Please contact your system administrator. Type is required in InputPhone tag'
      end

      it { expect(error_code).to be_nil }
    end

    context 'with no error code string' do
      let(:error_message) { nil }

      it { expect(error_code).to be_nil }
    end
  end

  context 'when reporting an error' do
    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }

    let(:error_code) { 'a:ServiceFaultFault' }
    let(:send_request) do
      message = { code: error_code, headers: {}, body: message_body}
      savon.expects(:search).with(message: {}).returns(message)
      VCR.use_cassette('send_request') do
        LexisNexis.send_request(lexis_nexis_client, :search, {})
      end
    end
    let(:message_body) do
      "<Envelope><Body><Fault><faultcode>a:ServiceFaultFault</faultcode><faultstring>" \
        "Error in deserializing body of request message for operation 'Search'.\n" \
        "There is an error in XML document (1, 854).\nInstance validation error: '' "\
        "is not a valid value for PhoneType.</faultstring><detail><ServiceFault><Message>" \
        "Error in deserializing body of request message for operation 'Search'.\nThere is an " \
        "error in XML document (1, 854).\nInstance validation error: '' is not a valid value for " \
        "PhoneType.</Message><Type>Error</Type></ServiceFault></detail></Fault>" \
        "</Body></Envelope>"
    end

    it { expect(send_request.success?).to eq(false) }
    it { expect(send_request.errors).not_to be_empty }
    it { expect(send_request.code).to eq(error_code) }
  end

  context 'when reporting a successful call' do
    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }

    let(:error_code) { 'a:ServiceFaultFault' }
    let(:message_body) { '<Envelope><Body><Input>Test</Input></Body></Envelope>' }
    let(:send_request) do
      message = { code: 200, headers: {}, body: message_body}
      savon.expects(:search).with(message: {}).returns(message)
      VCR.use_cassette('send_request') do
        LexisNexis.send_request(lexis_nexis_client, :search, {})
      end
    end

    it { expect(send_request.success?).to eq(true) }
    it { expect(send_request.errors).to be_nil }
    it { expect(send_request.code).to be_nil }
    it { expect(send_request.data).not_to be_nil }
    it { expect(send_request.data).to eq({ input: "Test" }) }
  end
end
