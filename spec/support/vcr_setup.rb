# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '../fixtures/vcr_cassettes/')
  c.hook_into :webmock
  c.before_record do |i|
    # Borrowed from https://github.com/mislav/movieapp/blob/4c4f9c109657cb922b12e3bdbb6f25ddf9ad7d0e/spec/support/vcr.rb#L161

    type, charset = Array(i.response.headers['Content-Type']).join(',').split(';')

    # This is here if you find VCR cassettes are recording ASCII responses that can't be decoded. It does make the
    #  response a little bit different from production, unfortunately. But it makes the response readable in VCR
    #  cassettes.
    i.response.body.force_encoding(Regexp.last_match(1)) if charset =~ /charset=(\S+)/

    if type =~ %r{[\/+]xml$} || type == 'text/javascript'
      begin
        i.response.body = Nokogiri::XML(i.response.body).to_xml
        i.response.update_content_length_header
      rescue Nokogiri::XML::SyntaxError => e
        warn "VCR Nokogiri XML syntax error for #{i.uri}: #{e}"
      end
    end
  end
end
