# frozen_string_literal: true

module BCPA
  # Represents a property from BCPA records
  class Property
    attr_reader :folio, :owner_name1, :owner_name2, :site_address1,
                :site_address2, :city, :zip, :use_code, :assessed_value

    def initialize(data)
      @folio = data['folioNumber']
      @owner_name1 = data['ownerName1']
      @owner_name2 = data['ownerName2']
      @site_address1 = data['siteAddress1']
      @site_address2 = data['siteAddress2']
      @city = data['siteCity']
      @zip = data['siteZip']
      @use_code = data['useCode']
      @assessed_value = data['assessedValue']
    end

    # Combined owner name
    def owner
      @owner ||= [owner_name1, owner_name2].compact.reject(&:empty?).join(' ')
    end

    # Full address
    def address
      @address ||= begin
        parts = [site_address1, site_address2].compact.reject(&:empty?)
        parts << "#{city}, FL #{zip}" if city
        parts.join(', ')
      end
    end

    # Extract unit number from address (e.g., #123)
    def unit_number
      @unit_number ||= begin
        match = site_address1&.match(/#(\d+)/)
        match ? match[1].to_i : nil
      end
    end

    # Convert to hash for serialization
    def to_h
      {
        folio: folio,
        owner: owner,
        owner_name1: owner_name1,
        owner_name2: owner_name2,
        address: address,
        site_address1: site_address1,
        site_address2: site_address2,
        city: city,
        zip: zip,
        unit_number: unit_number,
        use_code: use_code,
        assessed_value: assessed_value
      }
    end
  end
end
