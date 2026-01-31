# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'openssl'

module BCPA
  # API client for Broward County Property Appraiser
  class Client
    API_URL = 'https://web.bcpa.net/BcpaClient/search.aspx/GetData'

    def initialize
      @uri = URI.parse(API_URL)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @http.open_timeout = 10
      @http.read_timeout = 30
    end

    # Search by address, owner name, or other criteria
    # @param query [String] Search query
    # @param city [String] Optional city filter (e.g., "PL" for Plantation)
    # @param page_count [Integer] Number of results per page
    # @return [Array<Property>] Array of Property objects
    def search(query, city: '', page_count: 200)
      response = make_request(query, city, page_count)
      parse_response(response)
    end

    # Lookup a property by folio number
    # @param folio [String] Folio number
    # @return [Property, nil] Property object or nil if not found
    def folio(folio)
      results = search(folio)
      results.find { |p| p.folio == folio }
    end

    private

    def make_request(query, city, page_count)
      @http.start unless @http.started?

      request = Net::HTTP::Post.new(@uri.path)
      request['Content-Type'] = 'application/json; charset=utf-8'
      request.body = build_request_body(query, city, page_count)

      response = @http.request(request)

      raise APIError, "API request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def build_request_body(query, city, page_count)
      {
        value: query,
        cities: city,
        orderBy: '',
        pageNumber: '1',
        pageCount: page_count.to_s,
        arrayOfValues: '',
        selectedFromList: 'false',
        totalCount: '0'
      }.to_json
    end

    def parse_response(body)
      data = JSON.parse(body)
      results = data.dig('d', 'resultListk__BackingField') || []
      results.map { |r| Property.new(r) }
    rescue JSON::ParserError => e
      raise APIError, "Failed to parse API response: #{e.message}"
    end
  end
end
