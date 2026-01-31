# frozen_string_literal: true

module TestFactories
  def build_property_data(overrides = {})
    {
      'folioNumber' => '504108BD0010',
      'ownerName1' => 'SMITH, JOHN',
      'ownerName2' => '',
      'siteAddress1' => '9703 N NEW RIVER CANAL RD #100',
      'siteAddress2' => '',
      'siteCity' => 'PLANTATION',
      'siteZip' => '33324',
      'useCode' => '0400',
      'assessedValue' => 250_000
    }.merge(overrides)
  end
end
