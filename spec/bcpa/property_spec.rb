# frozen_string_literal: true

require "spec_helper"

RSpec.describe BCPA::Property do
  let(:data) do
    {
      "folioNumber" => "504108BD0010",
      "ownerName1" => "SMITH, JOHN",
      "ownerName2" => "SMITH, JANE",
      "siteAddress1" => "9703 N NEW RIVER CANAL RD #100",
      "siteAddress2" => "BLDG A",
      "siteCity" => "PLANTATION",
      "siteZip" => "33324",
      "useCode" => "0400",
      "assessedValue" => 250_000
    }
  end

  let(:property) { described_class.new(data) }

  describe "#owner" do
    it "combines owner names" do
      expect(property.owner).to eq("SMITH, JOHN SMITH, JANE")
    end

    it "handles missing owner_name2" do
      data["ownerName2"] = ""
      expect(property.owner).to eq("SMITH, JOHN")
    end
  end

  describe "#unit_number" do
    it "extracts unit number from address" do
      expect(property.unit_number).to eq(100)
    end

    it "returns nil when no unit number" do
      data["siteAddress1"] = "123 MAIN ST"
      expect(property.unit_number).to be_nil
    end
  end

  describe "#address" do
    it "formats full address" do
      expect(property.address).to include("9703 N NEW RIVER CANAL RD #100")
      expect(property.address).to include("PLANTATION, FL 33324")
    end
  end

  describe "#to_h" do
    it "returns hash representation" do
      hash = property.to_h
      expect(hash[:folio]).to eq("504108BD0010")
      expect(hash[:owner]).to eq("SMITH, JOHN SMITH, JANE")
      expect(hash[:unit_number]).to eq(100)
    end
  end
end
