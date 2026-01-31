# frozen_string_literal: true

require 'terminal-table'

module BCPA
  module Formatters
    # Table output formatter using terminal-table
    class Table < Base
      COLUMNS = %i[folio owner address unit_number].freeze

      def format(properties)
        rows = properties.map do |prop|
          COLUMNS.map { |col| truncate(prop.to_h[col].to_s, 40) }
        end

        table = Terminal::Table.new(
          headings: COLUMNS.map { |c| c.to_s.upcase.tr('_', ' ') },
          rows: rows
        )
        table.to_s
      end

      private

      def truncate(str, length)
        str.length > length ? "#{str[0, length - 3]}..." : str
      end
    end
  end
end
