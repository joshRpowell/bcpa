# frozen_string_literal: true

require 'csv'

module BCPA
  module Formatters
    # CSV output formatter
    class CSV < Base
      COLUMNS = %i[folio owner address unit_number assessed_value].freeze

      def format(properties)
        ::CSV.generate do |csv|
          csv << COLUMNS.map { |c| c.to_s.upcase.tr('_', ' ') }
          properties.each do |prop|
            h = prop.to_h
            csv << COLUMNS.map { |col| h[col] }
          end
        end
      end
    end
  end
end
