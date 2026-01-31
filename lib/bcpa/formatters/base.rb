# frozen_string_literal: true

module BCPA
  module Formatters
    # Base class for output formatters
    class Base
      def format(properties)
        raise NotImplementedError
      end

      def self.for(format_name)
        case format_name.to_s.downcase
        when 'json' then JSON.new
        when 'table' then Table.new
        when 'csv' then CSV.new
        else
          raise ArgumentError, "Unknown format: #{format_name}"
        end
      end
    end
  end
end
