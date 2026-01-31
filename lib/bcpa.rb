# frozen_string_literal: true

require_relative "bcpa/version"
require_relative "bcpa/property"
require_relative "bcpa/client"
require_relative "bcpa/formatters/base"
require_relative "bcpa/formatters/json"
require_relative "bcpa/formatters/table"
require_relative "bcpa/formatters/csv"
require_relative "bcpa/crossref/matcher"
require_relative "bcpa/crossref/report"
require_relative "bcpa/cli"

module BCPA
  class Error < StandardError; end
  class APIError < Error; end
end
