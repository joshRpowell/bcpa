# frozen_string_literal: true

require "csv"

module BCPA
  module Formatters
    # CSV output formatter
    class CSV < Base
      COLUMNS = [:folio, :owner, :address, :unit_number, :assessed_value].freeze

      def format(properties)
        ::CSV.generate do |csv|
          csv << COLUMNS.map { |c| c.to_s.upcase.tr("_", " ") }
          properties.each do |prop|
            csv << COLUMNS.map { |col| prop.to_h[col] }
          end
        end
      end
    end
  end
end
