# frozen_string_literal: true

require "json"

module BCPA
  module Formatters
    # JSON output formatter
    class JSON < Base
      def format(properties)
        data = properties.map(&:to_h)
        ::JSON.pretty_generate(data)
      end
    end
  end
end
