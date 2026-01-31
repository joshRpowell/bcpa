# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BCPA::Formatters::Base do
  describe '.for' do
    it 'returns JSON formatter for json' do
      formatter = described_class.for('json')
      expect(formatter).to be_a(BCPA::Formatters::JSON)
    end

    it 'returns JSON formatter for JSON (uppercase)' do
      formatter = described_class.for('JSON')
      expect(formatter).to be_a(BCPA::Formatters::JSON)
    end

    it 'returns Table formatter for table' do
      formatter = described_class.for('table')
      expect(formatter).to be_a(BCPA::Formatters::Table)
    end

    it 'returns Table formatter for Table (mixed case)' do
      formatter = described_class.for('Table')
      expect(formatter).to be_a(BCPA::Formatters::Table)
    end

    it 'returns CSV formatter for csv' do
      formatter = described_class.for('csv')
      expect(formatter).to be_a(BCPA::Formatters::CSV)
    end

    it 'returns CSV formatter for CSV (uppercase)' do
      formatter = described_class.for('CSV')
      expect(formatter).to be_a(BCPA::Formatters::CSV)
    end

    it 'accepts symbols' do
      formatter = described_class.for(:json)
      expect(formatter).to be_a(BCPA::Formatters::JSON)
    end

    it 'raises ArgumentError for unknown format' do
      expect { described_class.for('unknown') }.to raise_error(ArgumentError, 'Unknown format: unknown')
    end

    it 'raises ArgumentError for xml format' do
      expect { described_class.for('xml') }.to raise_error(ArgumentError, 'Unknown format: xml')
    end

    it 'raises ArgumentError for empty string' do
      expect { described_class.for('') }.to raise_error(ArgumentError, 'Unknown format: ')
    end
  end

  describe '#format' do
    it 'raises NotImplementedError when called on base class' do
      formatter = described_class.new
      expect { formatter.format([]) }.to raise_error(NotImplementedError)
    end
  end
end
