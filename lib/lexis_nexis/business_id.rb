# frozen_string_literal: true

module LexisNexis
  module BusinessID
    include LexisNexis
    extend self
    SEARCH_METHOD = :business_instant_id
    DEFAULT_QUERY_ARRAY = %w(user options search_by)
    DEFAULT_USER_OPTIONS = ["PartnerSignup", "FPS", 5, 3] # reference_code, billing_code, glb_purpose [5: code for risk use], dl_purpose [3: code for business verification]
    SEARCH_OPTIONS_ARRAY = %w(alternate_company_name company_address fein company_phone authorized_representative use_dob_filter dob_radius)
    WATCHLISTS = %w(BES CFTC DTC EUDT FBI FCEN FAR IMW OFAC OCC OSFI PEP SDT BIS UNNT WBIF)
    DOB_MATCHES = %w(FuzzyCCYYMMDD FuzzyCCYYMM RadiusCCYY ExactCCYYMMDD ExactCCYYMM)
    #options defaults
    INCLUDE_MS_OVERRIDE = 0
    INCLUDE_DL_VERIFICATION = 0
    PO_BOX_COMPLIANCE = 0
    GLOBAL_WATCHLIST_THRESHOLD = 0.84
    BUSINESS_DEFENDER = 0
    INCLUDE_ALL_RISK_INDICATORS = 0

    def find_by_company_name(name, opts = {})
      search = search_hash(name)
      search["SearchBy"].merge!(build_hash(SEARCH_OPTIONS_ARRAY, opts))
      options = options_hash
      LexisNexis.send_request(client, SEARCH_METHOD, wrap_request(search, options))
    end

    def user_hash(reference_code, billing_code, glb_purpose, dl_purpose, enduser = nil)
      hash = {
        "ReferenceCode" => reference_code,
        "BillingCode" => billing_code,
        "GLBPurpose" => glb_purpose,
        "DLPurpose" => dl_purpose,
      }
      hash["EndUser"] = enduser if !enduser.nil?
      hash
    end

    def wrap_request(*hashes)
      auth_hash = { "User" => user_hash(*DEFAULT_USER_OPTIONS)}
      hashes.each{ |hash| auth_hash.merge!(hash) }
      auth_hash
    end

    def search_hash(company_name)
      {
        "SearchBy" => {
          "CompanyName" => company_name
        }
      }
    end

    def enduser_hash(company_name, street, state, zip)
      {
        "CompanyName" => company_name,
        "StreetAddress1" => street,
        "State" => state,
        "Zip5" => zip
      }
    end

    def authorized_representative_hash(opts)
      hash_keys = %w(name address age dob ssn driver_license_number driver_license_state phone10 former_last_name)
      hash = {}
      if opts.is_a?(Hash) && !opts.empty?
        opts.each do |option, value|
          option_string = option.to_s
          hash[camelize_string(option_string)] = value if hash_keys.include?(option_string)
        end
      end
      hash
    end

    def dob_hash(year, month, day)
      {
        "Year" => year,
        "Month" => month,
        "Day" => day
      }
    end

    def name_hash(first_name, last_name, suffix = nil, middle_name = nil)
      name = {
        "First" => first_name,
        "Last" => last_name
      }
      name["Suffix"] = suffix if !suffix.nil?
      name["Middle"] = middle_name if !middle_name.nil?
      name
    end

    def options_hash(opts = {})
      watchlists_array = opts[:watchlists] || WATCHLISTS
      {
        "Watchlists" => {
          "WatchList" => watchlists_array
        },
        "IncludeMSOverride" => opts[:include_ms_override] || INCLUDE_MS_OVERRIDE,
        "IncludeDLVerification" => opts[:include_dl_verification] || INCLUDE_DL_VERIFICATION,
        "PoBoxCompliance" => opts[:po_box_compliance] || PO_BOX_COMPLIANCE,
        "GlobalWatchlistThreshold" => opts[:global_watchlist_threshold] || GLOBAL_WATCHLIST_THRESHOLD,
        "IncludeModels" => {
          "BusinessDefender" => opts[:business_defender] || BUSINESS_DEFENDER
        },
        "IncludeAllRiskIndicators" => opts[:include_all_risk_indicators] || INCLUDE_ALL_RISK_INDICATORS
      }
    end

    def address_hash(address, city, state, zip)
      {
        "StreetAddress1" => address,
        "State" => state,
        "City" => city,
        "Zip5" => zip
      }
    end

    private

    def client
      @client ||= LexisNexis.client(::LEXIS_NEXIS_WSDL, log: true)
    end

    def build_hash(indexes, options)
      hash = {}
      if !options.empty? && !indexes.empty?
        indexes.each do |hash_key|
          if hash_key.include?("_")
            key = camelize_string(hash_key)
          else
            key = hash_key.upcase
          end
          hash[key] = options[hash_key.to_sym] if !options[hash_key.to_sym].nil?
        end
      end
      hash
    end

    def camelize_string(str)
      str.gsub(/(?:^|_)([a-z])/) { Regexp.last_match(1).upcase }
    end
  end
end
