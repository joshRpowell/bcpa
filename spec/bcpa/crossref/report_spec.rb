# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BCPA::Crossref::Report do
  let(:report) { described_class.new }
  let(:yaml_path) { File.expand_path('../../fixtures/test-owners.yaml', __dir__) }

  # Helper to build a Property object from test data
  def build_property(folio:, owner:, address:, unit_number:)
    BCPA::Property.new(
      'folioNumber' => folio,
      'ownerName1' => owner,
      'ownerName2' => '',
      'siteAddress1' => "#{address} ##{unit_number}",
      'siteAddress2' => '',
      'siteCity' => 'PLANTATION',
      'siteZip' => '33324',
      'useCode' => '0400',
      'assessedValue' => 250_000
    )
  end

  describe '#run' do
    context 'with matching owners' do
      let(:properties) do
        [
          build_property(folio: 'FOLIO100', owner: 'KELLY, ANDREA ISABEL', address: '9703 N NEW RIVER CANAL RD',
                         unit_number: 100),
          build_property(folio: 'FOLIO101', owner: 'STIGALE, JOANN', address: '9703 N NEW RIVER CANAL RD',
                         unit_number: 101)
        ]
      end

      it 'identifies matching owners' do
        report.run(yaml_path, properties)

        expect(report.matches.length).to eq(2)
        expect(report.discrepancies).to be_empty
        expect(report.not_found.length).to eq(1) # Unit 200 is not in properties
      end

      it 'records match details correctly' do
        report.run(yaml_path, properties)

        match = report.matches.find { |m| m[:unit] == 100 }
        expect(match[:coupon]).to eq('KELLY,ANDREA ISABEL')
        expect(match[:bcpa]).to eq('KELLY, ANDREA ISABEL')
        expect(match[:folio]).to eq('FOLIO100')
      end
    end

    context 'with discrepancies' do
      let(:properties) do
        [
          build_property(folio: 'FOLIO100', owner: 'DIFFERENT, OWNER', address: '9703 N NEW RIVER CANAL RD',
                         unit_number: 100),
          build_property(folio: 'FOLIO101', owner: 'STIGALE, JOANN', address: '9703 N NEW RIVER CANAL RD',
                         unit_number: 101)
        ]
      end

      it 'identifies discrepancies when owners differ' do
        report.run(yaml_path, properties)

        expect(report.matches.length).to eq(1)
        expect(report.discrepancies.length).to eq(1)
      end

      it 'records discrepancy details correctly' do
        report.run(yaml_path, properties)

        discrepancy = report.discrepancies.first
        expect(discrepancy[:unit]).to eq(100)
        expect(discrepancy[:coupon]).to eq('KELLY,ANDREA ISABEL')
        expect(discrepancy[:bcpa]).to eq('DIFFERENT, OWNER')
        expect(discrepancy[:folio]).to eq('FOLIO100')
        expect(discrepancy[:type]).to eq('villa')
        expect(discrepancy[:address]).to include('9703 N NEW RIVER CANAL RD')
      end
    end

    context 'with not found units' do
      let(:properties) do
        [
          build_property(folio: 'FOLIO100', owner: 'KELLY, ANDREA ISABEL', address: '9703 N NEW RIVER CANAL RD',
                         unit_number: 100)
        ]
      end

      it 'identifies units not found in BCPA' do
        report.run(yaml_path, properties)

        expect(report.not_found.length).to eq(2) # Units 101 and 200
        not_found_units = report.not_found.map { |u| u[:unit] }
        expect(not_found_units).to include(101, 200)
      end

      it 'records not found details correctly' do
        report.run(yaml_path, properties)

        not_found = report.not_found.find { |u| u[:unit] == 101 }
        expect(not_found[:owner]).to eq('STIGALE,JOANN')
        expect(not_found[:type]).to eq('villa')
      end
    end
  end

  describe '#to_s' do
    let(:properties) do
      [
        build_property(folio: 'FOLIO100', owner: 'DIFFERENT, OWNER', address: '9703 N NEW RIVER CANAL RD',
                       unit_number: 100),
        build_property(folio: 'FOLIO101', owner: 'STIGALE, JOANN', address: '9703 N NEW RIVER CANAL RD',
                       unit_number: 101)
      ]
    end

    before { report.run(yaml_path, properties) }

    it 'returns a string report' do
      output = report.to_s
      expect(output).to be_a(String)
    end

    it 'includes the header' do
      output = report.to_s
      expect(output).to include('=== BCPA CROSS-REFERENCE REPORT ===')
    end

    it 'includes summary section' do
      output = report.to_s
      expect(output).to include('SUMMARY:')
      expect(output).to include('Total units in file: 3')
      expect(output).to include('Owners MATCH: 1')
      expect(output).to include('Owners DIFFER: 1')
      expect(output).to include('Not found in BCPA: 1')
    end

    it 'includes discrepancy details' do
      output = report.to_s
      expect(output).to include('=== OWNERSHIP DISCREPANCIES ===')
      expect(output).to include('Unit 100 (villa)')
      expect(output).to include('Folio:   FOLIO100')
      expect(output).to include('File:    KELLY,ANDREA ISABEL')
      expect(output).to include('BCPA:    DIFFERENT, OWNER')
    end

    it 'includes not found section' do
      output = report.to_s
      expect(output).to include('=== NOT FOUND IN BCPA ===')
      expect(output).to include('Unit 200: NONEXISTENT,OWNER')
    end
  end

  describe '#to_json' do
    let(:properties) do
      [
        build_property(folio: 'FOLIO100', owner: 'DIFFERENT, OWNER', address: '9703 N NEW RIVER CANAL RD',
                       unit_number: 100),
        build_property(folio: 'FOLIO101', owner: 'STIGALE, JOANN', address: '9703 N NEW RIVER CANAL RD',
                       unit_number: 101)
      ]
    end

    before { report.run(yaml_path, properties) }

    it 'returns valid JSON' do
      json_output = report.to_json
      expect { JSON.parse(json_output) }.not_to raise_error
    end

    it 'includes generated timestamp' do
      parsed = JSON.parse(report.to_json)
      expect(parsed).to have_key('generated')
      expect { Time.iso8601(parsed['generated']) }.not_to raise_error
    end

    it 'includes summary statistics' do
      parsed = JSON.parse(report.to_json)
      summary = parsed['summary']

      expect(summary['total_units']).to eq(3)
      expect(summary['found_in_bcpa']).to eq(2)
      expect(summary['owners_match']).to eq(1)
      expect(summary['owners_differ']).to eq(1)
      expect(summary['not_found']).to eq(1)
    end

    it 'includes discrepancy details' do
      parsed = JSON.parse(report.to_json)
      discrepancies = parsed['discrepancies']

      expect(discrepancies.length).to eq(1)
      expect(discrepancies.first['unit']).to eq(100)
      expect(discrepancies.first['coupon']).to eq('KELLY,ANDREA ISABEL')
      expect(discrepancies.first['bcpa']).to eq('DIFFERENT, OWNER')
    end

    it 'includes not found units' do
      parsed = JSON.parse(report.to_json)
      not_found = parsed['not_found_units']

      expect(not_found.length).to eq(1)
      expect(not_found.first['unit']).to eq(200)
      expect(not_found.first['owner']).to eq('NONEXISTENT,OWNER')
    end
  end
end
