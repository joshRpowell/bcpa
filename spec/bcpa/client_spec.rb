# frozen_string_literal: true

require "spec_helper"

RSpec.describe BCPA::Client do
  let(:client) { described_class.new }

  describe "#search" do
    let(:api_response) do
      {
        "d" => {
          "resultListk__BackingField" => [
            {
              "folioNumber" => "504108BD0010",
              "ownerName1" => "SMITH, JOHN",
              "ownerName2" => "",
              "siteAddress1" => "9703 N NEW RIVER CANAL RD #100",
              "siteAddress2" => "",
              "siteCity" => "PLANTATION",
              "siteZip" => "33324",
              "useCode" => "0400",
              "assessedValue" => 250_000
            }
          ]
        }
      }
    end

    before do
      stub_request(:post, "https://web.bcpa.net/BcpaClient/search.aspx/GetData")
        .to_return(status: 200, body: api_response.to_json)
    end

    it "returns array of Property objects" do
      results = client.search("9703 N NEW RIVER CANAL")
      expect(results).to be_an(Array)
      expect(results.first).to be_a(BCPA::Property)
    end

    it "parses property data correctly" do
      results = client.search("9703 N NEW RIVER CANAL")
      prop = results.first

      expect(prop.folio).to eq("504108BD0010")
      expect(prop.owner).to eq("SMITH, JOHN")
      expect(prop.unit_number).to eq(100)
    end
  end

  describe "#folio" do
    let(:api_response) do
      {
        "d" => {
          "resultListk__BackingField" => [
            { "folioNumber" => "504108BD0010", "ownerName1" => "SMITH", "ownerName2" => "",
              "siteAddress1" => "100 MAIN ST", "siteCity" => "PLANTATION", "siteZip" => "33324" },
            { "folioNumber" => "504108BD0020", "ownerName1" => "JONES", "ownerName2" => "",
              "siteAddress1" => "101 MAIN ST", "siteCity" => "PLANTATION", "siteZip" => "33324" }
          ]
        }
      }
    end

    before do
      stub_request(:post, "https://web.bcpa.net/BcpaClient/search.aspx/GetData")
        .to_return(status: 200, body: api_response.to_json)
    end

    it "returns matching property" do
      prop = client.folio("504108BD0020")
      expect(prop.owner).to eq("JONES")
    end
  end
end
