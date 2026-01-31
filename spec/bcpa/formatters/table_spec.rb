# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BCPA::Formatters::Table do
  let(:formatter) { described_class.new }

  let(:property_data) { build_property_data }

  let(:property) { BCPA::Property.new(property_data) }
  let(:properties) { [property] }

  describe '#format' do
    it 'returns a string' do
      output = formatter.format(properties)
      expect(output).to be_a(String)
    end

    it 'includes table border characters' do
      output = formatter.format(properties)
      expect(output).to include('+')
      expect(output).to include('|')
      expect(output).to include('-')
    end

    it 'includes FOLIO header' do
      output = formatter.format(properties)
      expect(output).to include('FOLIO')
    end

    it 'includes OWNER header' do
      output = formatter.format(properties)
      expect(output).to include('OWNER')
    end

    it 'includes ADDRESS header' do
      output = formatter.format(properties)
      expect(output).to include('ADDRESS')
    end

    it 'includes UNIT NUMBER header' do
      output = formatter.format(properties)
      expect(output).to include('UNIT NUMBER')
    end

    it 'includes folio value' do
      output = formatter.format(properties)
      expect(output).to include('504108BD0010')
    end

    it 'includes owner value' do
      output = formatter.format(properties)
      expect(output).to include('SMITH, JOHN')
    end

    it 'includes unit number value' do
      output = formatter.format(properties)
      expect(output).to include('100')
    end

    context 'with long values' do
      let(:property_data) do
        {
          'folioNumber' => '504108BD0010',
          'ownerName1' => 'VERYLONGLASTNAME, FIRSTNAME MIDDLENAME ANOTHERMIDDLENAME',
          'ownerName2' => '',
          'siteAddress1' => '9703 N NEW RIVER CANAL RD #100',
          'siteAddress2' => '',
          'siteCity' => 'PLANTATION',
          'siteZip' => '33324',
          'useCode' => '0400',
          'assessedValue' => 250_000
        }
      end

      it 'truncates values longer than 40 characters' do
        output = formatter.format(properties)
        # The owner name is longer than 40 characters, should be truncated with ...
        expect(output).to include('...')
      end

      it 'truncated values end with ellipsis' do
        output = formatter.format(properties)
        # Find the truncated owner name (37 chars + "...")
        expect(output).to match(/VERYLONGLASTNAME, FIRSTNAME MIDDLENAM\.\.\./)
      end
    end

    context 'with values exactly 40 characters' do
      let(:property_data) do
        {
          'folioNumber' => '504108BD0010',
          # Exactly 40 characters
          'ownerName1' => 'A' * 40,
          'ownerName2' => '',
          'siteAddress1' => '9703 N NEW RIVER CANAL RD #100',
          'siteAddress2' => '',
          'siteCity' => 'PLANTATION',
          'siteZip' => '33324',
          'useCode' => '0400',
          'assessedValue' => 250_000
        }
      end

      it 'does not truncate values of exactly 40 characters' do
        output = formatter.format(properties)
        expect(output).to include('A' * 40)
        expect(output).not_to include("#{'A' * 37}...")
      end
    end

    context 'with multiple properties' do
      let(:property2_data) do
        {
          'folioNumber' => '504108BD0020',
          'ownerName1' => 'JONES, BOB',
          'ownerName2' => '',
          'siteAddress1' => '9703 N NEW RIVER CANAL RD #101',
          'siteAddress2' => '',
          'siteCity' => 'PLANTATION',
          'siteZip' => '33324',
          'useCode' => '0400',
          'assessedValue' => 275_000
        }
      end

      let(:property2) { BCPA::Property.new(property2_data) }
      let(:properties) { [property, property2] }

      it 'includes all properties' do
        output = formatter.format(properties)
        expect(output).to include('504108BD0010')
        expect(output).to include('504108BD0020')
      end

      it 'includes all owners' do
        output = formatter.format(properties)
        expect(output).to include('SMITH, JOHN')
        expect(output).to include('JONES, BOB')
      end
    end

    context 'with empty properties array' do
      it 'returns table with only headers' do
        output = formatter.format([])
        expect(output).to include('FOLIO')
        expect(output).to include('OWNER')
        # Should still have table structure but no data rows
        lines = output.split("\n")
        # Header separator + headers + footer = 3 lines minimum
        expect(lines.length).to be >= 3
      end
    end
  end
end
