# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BCPA::Formatters::JSON do
  let(:formatter) { described_class.new }

  let(:property_data) do
    {
      'folioNumber' => '504108BD0010',
      'ownerName1' => 'SMITH, JOHN',
      'ownerName2' => 'SMITH, JANE',
      'siteAddress1' => '9703 N NEW RIVER CANAL RD #100',
      'siteAddress2' => 'BLDG A',
      'siteCity' => 'PLANTATION',
      'siteZip' => '33324',
      'useCode' => '0400',
      'assessedValue' => 250_000
    }
  end

  let(:property) { BCPA::Property.new(property_data) }
  let(:properties) { [property] }

  describe '#format' do
    it 'returns valid JSON' do
      output = formatter.format(properties)
      expect { JSON.parse(output) }.not_to raise_error
    end

    it 'returns a pretty-printed JSON string' do
      output = formatter.format(properties)
      expect(output).to include("\n")
    end

    it 'returns an array of property objects' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed).to be_an(Array)
      expect(parsed.length).to eq(1)
    end

    it 'includes folio field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['folio']).to eq('504108BD0010')
    end

    it 'includes owner field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['owner']).to eq('SMITH, JOHN SMITH, JANE')
    end

    it 'includes owner_name1 field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['owner_name1']).to eq('SMITH, JOHN')
    end

    it 'includes owner_name2 field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['owner_name2']).to eq('SMITH, JANE')
    end

    it 'includes address field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['address']).to include('9703 N NEW RIVER CANAL RD #100')
      expect(parsed.first['address']).to include('PLANTATION, FL 33324')
    end

    it 'includes site_address1 field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['site_address1']).to eq('9703 N NEW RIVER CANAL RD #100')
    end

    it 'includes site_address2 field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['site_address2']).to eq('BLDG A')
    end

    it 'includes city field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['city']).to eq('PLANTATION')
    end

    it 'includes zip field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['zip']).to eq('33324')
    end

    it 'includes unit_number field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['unit_number']).to eq(100)
    end

    it 'includes use_code field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['use_code']).to eq('0400')
    end

    it 'includes assessed_value field' do
      output = formatter.format(properties)
      parsed = JSON.parse(output)
      expect(parsed.first['assessed_value']).to eq(250_000)
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
        parsed = JSON.parse(output)
        expect(parsed.length).to eq(2)
      end

      it 'formats each property correctly' do
        output = formatter.format(properties)
        parsed = JSON.parse(output)
        folios = parsed.map { |p| p['folio'] }
        expect(folios).to contain_exactly('504108BD0010', '504108BD0020')
      end
    end

    context 'with empty properties array' do
      it 'returns empty JSON array' do
        output = formatter.format([])
        parsed = JSON.parse(output)
        expect(parsed).to eq([])
      end
    end
  end
end
