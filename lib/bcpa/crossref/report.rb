# frozen_string_literal: true

require 'yaml'
require 'json'

module BCPA
  module Crossref
    # Cross-reference report generator
    class Report
      attr_reader :matches, :discrepancies, :not_found, :units

      def initialize
        @matcher = Matcher.new
        @matches = []
        @discrepancies = []
        @not_found = []
        @units = []
      end

      # Run cross-reference between YAML unit data and BCPA properties
      # @param yaml_path [String] Path to unit owners YAML file
      # @param properties [Array<Property>] BCPA property records
      def run(yaml_path, properties)
        @units = load_units(yaml_path)
        bcpa_by_unit = index_by_unit(properties)

        @units.each do |unit|
          bcpa_prop = bcpa_by_unit[unit[:unit]]

          if bcpa_prop.nil?
            @not_found << unit
          elsif @matcher.match?(unit[:owner], bcpa_prop.owner)
            @matches << {
              unit: unit[:unit],
              coupon: unit[:owner],
              bcpa: bcpa_prop.owner,
              folio: bcpa_prop.folio
            }
          else
            @discrepancies << {
              unit: unit[:unit],
              type: unit[:type],
              coupon: unit[:owner],
              bcpa: bcpa_prop.owner,
              folio: bcpa_prop.folio,
              address: bcpa_prop.address
            }
          end
        end
      end

      # Generate text report
      def to_s
        lines = summary_lines
        lines.concat(discrepancy_lines) if discrepancies.any?
        lines.concat(not_found_lines) if not_found.any?
        lines.join("\n")
      end

      # Generate JSON report
      def to_json(*_args)
        {
          generated: Time.now.iso8601,
          summary: {
            total_units: units.length,
            found_in_bcpa: matches.length + discrepancies.length,
            owners_match: matches.length,
            owners_differ: discrepancies.length,
            not_found: not_found.length
          },
          discrepancies: discrepancies,
          not_found_units: not_found.map { |u| { unit: u[:unit], owner: u[:owner] } }
        }.to_json
      end

      private

      def summary_lines
        [
          '=== BCPA CROSS-REFERENCE REPORT ===',
          "Generated: #{Time.now.strftime('%Y-%m-%d')}",
          '',
          'SUMMARY:',
          "  Total units in file: #{units.length}",
          "  Found in BCPA: #{matches.length + discrepancies.length}",
          "  Owners MATCH: #{matches.length}",
          "  Owners DIFFER: #{discrepancies.length}",
          "  Not found in BCPA: #{not_found.length}",
          ''
        ]
      end

      def discrepancy_lines
        lines = ['=== OWNERSHIP DISCREPANCIES ===', '(Owner in file differs from county records)', '']
        discrepancies.sort_by { |d| d[:unit] }.each do |d|
          lines << "Unit #{d[:unit]} (#{d[:type]})"
          lines << "  Folio:   #{d[:folio]}"
          lines << "  Address: #{d[:address]}"
          lines << "  File:    #{d[:coupon]}"
          lines << "  BCPA:    #{d[:bcpa]}"
          lines << ''
        end
        lines
      end

      def not_found_lines
        lines = ['=== NOT FOUND IN BCPA ===']
        not_found.sort_by { |u| u[:unit] }.each { |u| lines << "Unit #{u[:unit]}: #{u[:owner]}" }
        lines
      end

      def load_units(yaml_path)
        data = YAML.safe_load_file(yaml_path, permitted_classes: [], permitted_symbols: [], aliases: false)
        (data['units'] || []).map do |u|
          {
            unit: u['unit'],
            owner: u['owner'],
            type: u['type']
          }
        end
      end

      def index_by_unit(properties)
        properties.each_with_object({}) do |prop, hash|
          unit_num = prop.unit_number
          hash[unit_num] = prop if unit_num
        end
      end
    end
  end
end
