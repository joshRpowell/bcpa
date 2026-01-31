# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BCPA::Formatters::CSV do
  let(:formatter) { described_class.new }

  let(:property_data) { build_property_data }

  let(:property) { BCPA::Property.new(property_data) }
  let(:properties) { [property] }

  describe '#format' do
    it 'returns a string' do
      output = formatter.format(properties)
      expect(output).to be_a(String)
    end

    it 'returns valid CSV that can be parsed' do
      output = formatter.format(properties)
      expect { CSV.parse(output) }.not_to raise_error
    end

    it 'has header row' do
      output = formatter.format(properties)
      parsed = CSV.parse(output)
      headers = parsed.first

      expect(headers).to include('FOLIO')
      expect(headers).to include('OWNER')
      expect(headers).to include('ADDRESS')
      expect(headers).to include('UNIT NUMBER')
      expect(headers).to include('ASSESSED VALUE')
    end

    it 'has correct number of columns in header' do
      output = formatter.format(properties)
      parsed = CSV.parse(output)
      expect(parsed.first.length).to eq(5)
    end

    it 'has data row with correct values' do
      output = formatter.format(properties)
      parsed = CSV.parse(output)
      data_row = parsed[1]

      expect(data_row[0]).to eq('504108BD0010') # FOLIO
      expect(data_row[1]).to eq('SMITH, JOHN')  # OWNER
      expect(data_row[3]).to eq('100')          # UNIT NUMBER
      expect(data_row[4]).to eq('250000')       # ASSESSED VALUE
    end

    it 'includes address in data row' do
      output = formatter.format(properties)
      parsed = CSV.parse(output)
      data_row = parsed[1]

      expect(data_row[2]).to include('9703 N NEW RIVER CANAL RD')
      expect(data_row[2]).to include('PLANTATION')
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

      it 'has correct total row count (header + data)' do
        output = formatter.format(properties)
        parsed = CSV.parse(output)
        expect(parsed.length).to eq(3) # 1 header + 2 data rows
      end

      it 'includes all properties in output' do
        output = formatter.format(properties)
        parsed = CSV.parse(output)
        folios = parsed[1..].map { |row| row[0] }
        expect(folios).to contain_exactly('504108BD0010', '504108BD0020')
      end

      it 'maintains column alignment across rows' do
        output = formatter.format(properties)
        parsed = CSV.parse(output)
        parsed.each do |row|
          expect(row.length).to eq(5)
        end
      end
    end

    context 'with empty properties array' do
      it 'returns CSV with only header row' do
        output = formatter.format([])
        parsed = CSV.parse(output)
        expect(parsed.length).to eq(1)
        expect(parsed.first).to include('FOLIO')
      end
    end

    context 'with values containing commas' do
      let(:property_data) do
        {
          'folioNumber' => '504108BD0010',
          'ownerName1' => 'SMITH, JOHN',
          'ownerName2' => 'SMITH, JANE',
          'siteAddress1' => '9703 N NEW RIVER CANAL RD #100',
          'siteAddress2' => '',
          'siteCity' => 'PLANTATION',
          'siteZip' => '33324',
          'useCode' => '0400',
          'assessedValue' => 250_000
        }
      end

      it 'properly escapes comma-containing values' do
        output = formatter.format(properties)
        parsed = CSV.parse(output)
        # Owner field combines both names with a space, resulting in commas in the value
        owner = parsed[1][1]
        expect(owner).to eq('SMITH, JOHN SMITH, JANE')
      end
    end

    context 'with nil values' do
      let(:property_data) do
        {
          'folioNumber' => '504108BD0010',
          'ownerName1' => 'SMITH, JOHN',
          'ownerName2' => '',
          'siteAddress1' => '123 MAIN ST', # No unit number
          'siteAddress2' => '',
          'siteCity' => 'PLANTATION',
          'siteZip' => '33324',
          'useCode' => '0400',
          'assessedValue' => nil
        }
      end

      it 'handles nil unit_number' do
        output = formatter.format(properties)
        parsed = CSV.parse(output)
        expect(parsed[1][3]).to be_nil.or eq('')
      end

      it 'handles nil assessed_value' do
        output = formatter.format(properties)
        parsed = CSV.parse(output)
        expect(parsed[1][4]).to be_nil.or eq('')
      end
    end
  end
end
