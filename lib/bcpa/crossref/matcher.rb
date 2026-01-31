# frozen_string_literal: true

module BCPA
  module Crossref
    # Name matching logic for comparing owner records
    class Matcher
      # Words to strip from names before comparison
      NOISE_WORDS = %w[LLC INC CORP TRSTEE TR REV JR SR II III IV ETAL LIV].freeze
      NOISE_PATTERN = /(#{NOISE_WORDS.join('|')})/i

      # Check if two owner names match by comparing significant words
      # @param name1 [String] First owner name (e.g., from coupon/YAML)
      # @param name2 [String] Second owner name (e.g., from BCPA)
      # @return [Boolean] True if names share at least one significant word
      def match?(name1, name2)
        words1 = normalize(name1)
        words2 = normalize(name2)
        words1.any? { |w1| words2.any? { |w2| w1 == w2 } }
      end

      private

      # Normalize a name: uppercase, remove noise words, extract significant words
      def normalize(name)
        name.upcase
            .gsub(/[^A-Z\s]/, ' ')        # Replace non-letters with spaces
            .gsub(NOISE_PATTERN, '')      # Remove noise words
            .gsub(/H\s*E/, '')            # Remove H/E (husband/estate)
            .split(/\s+/)                 # Split on whitespace
            .reject { |w| w.length <= 2 } # Keep words > 2 chars
      end
    end
  end
end
