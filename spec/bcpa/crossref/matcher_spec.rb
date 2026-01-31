# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BCPA::Crossref::Matcher do
  let(:matcher) { described_class.new }

  describe '#match?' do
    it 'matches identical names' do
      expect(matcher.match?('SMITH, JOHN', 'SMITH, JOHN')).to be true
    end

    it 'matches names in different order' do
      expect(matcher.match?('JOHN SMITH', 'SMITH JOHN')).to be true
    end

    it 'matches when at least one significant word matches' do
      expect(matcher.match?('JOHN SMITH', 'SMITH, JANE')).to be true
    end

    it 'ignores LLC suffix' do
      expect(matcher.match?('SMITH LLC', 'SMITH')).to be true
    end

    it 'ignores INC suffix' do
      expect(matcher.match?('ACME INC', 'ACME')).to be true
    end

    it 'ignores TRSTEE suffix' do
      expect(matcher.match?('SMITH TRSTEE', 'SMITH')).to be true
    end

    it 'ignores TR suffix' do
      expect(matcher.match?('SMITH TR', 'SMITH')).to be true
    end

    it 'ignores JR suffix' do
      expect(matcher.match?('JOHN SMITH JR', 'JOHN SMITH')).to be true
    end

    it 'is case insensitive' do
      expect(matcher.match?('Smith, John', 'SMITH, JOHN')).to be true
    end

    it 'ignores non-letter characters' do
      expect(matcher.match?('SMITH-JONES', 'SMITH JONES')).to be true
    end

    it 'ignores short words' do
      expect(matcher.match?('A SMITH', 'SMITH B')).to be true
    end

    it 'returns false for no matching words' do
      expect(matcher.match?('SMITH, JOHN', 'JONES, JANE')).to be false
    end
  end
end
