# frozen_string_literal: true

module BCPA
  module Crossref
    # Name matching logic for comparing owner records
    class Matcher
      # Words to strip from names before comparison
      NOISE_WORDS = %w[LLC INC CORP TRSTEE TR REV JR SR II III IV ETAL LIV].freeze
      NOISE_PATTERN = /(#{NOISE_WORDS.join('|')})/i
      NON_ALPHA_PATTERN = /[^A-Z\s]/
      HUSBAND_ESTATE_PATTERN = /H\s*E/
      WHITESPACE_PATTERN = /\s+/

      # Check if two owner names match by comparing significant words
      # @param name1 [String] First owner name (e.g., from coupon/YAML)
      # @param name2 [String] Second owner name (e.g., from BCPA)
      # @return [Boolean] True if names share at least one significant word
      def match?(name1, name2)
        words1 = normalize(name1)
        words2 = normalize(name2)
        (words1 & words2).any?
      end

      private

      # Normalize a name: uppercase, remove noise words, extract significant words
      def normalize(name)
        name.upcase
            .gsub(NON_ALPHA_PATTERN, ' ')
            .gsub(NOISE_PATTERN, '')
            .gsub(HUSBAND_ESTATE_PATTERN, '')
            .split(WHITESPACE_PATTERN)
            .reject { |w| w.length <= 2 }
      end
    end
  end
end
