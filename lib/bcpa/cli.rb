# frozen_string_literal: true

require 'thor'

module BCPA
  # Command-line interface for BCPA
  class CLI < Thor
    class_option :format, type: :string, default: 'table',
                          desc: 'Output format (json, table, csv)'
    class_option :output, type: :string,
                          desc: 'Write output to file'

    desc 'search QUERY', 'Search by address or owner name'
    option :city, type: :string, default: '',
                  desc: 'City filter (e.g., PL for Plantation)'
    def search(query)
      client = Client.new
      properties = client.search(query, city: options[:city])

      if properties.empty?
        say "No properties found for: #{query}", :yellow
        return
      end

      say "Found #{properties.length} properties\n\n", :green
      output(properties)
    end

    desc 'folio FOLIO_NUMBER', 'Lookup property by folio number'
    def folio(folio_number)
      client = Client.new
      property = client.folio(folio_number)

      if property.nil?
        say "No property found for folio: #{folio_number}", :yellow
        return
      end

      output([property])
    end

    desc 'crossref YAML_FILE', 'Cross-reference owners against BCPA records'
    option :searches, type: :array,
                      default: ['9703 N NEW RIVER CANAL', '9701 N NEW RIVER CANAL',
                                'MOCKINGBIRD LN', 'COCO PLUM'],
                      desc: 'Address patterns to search'
    option :city, type: :string, default: 'PL',
                  desc: 'City filter for searches'
    def crossref(yaml_file)
      unless File.exist?(yaml_file)
        say "File not found: #{yaml_file}", :red
        exit 1
      end

      say 'Fetching BCPA records...', :cyan
      client = Client.new
      all_properties = fetch_all_properties(client, options[:searches], options[:city])
      say "Found #{all_properties.length} properties\n\n", :green

      report = Crossref::Report.new
      report.run(yaml_file, all_properties)

      if options[:format] == 'json'
        write_output(report.to_json)
      else
        say report.to_s
        write_json_output(report) if options[:output]
      end
    end

    desc 'version', 'Print version'
    def version
      say "bcpa #{VERSION}"
    end

    private

    def validate_output_path(path)
      expanded = File.expand_path(path)
      raise ArgumentError, 'Cannot write to hidden files' if File.basename(expanded).start_with?('.')

      expanded
    end

    def output(properties)
      formatter = Formatters::Base.for(options[:format])
      result = formatter.format(properties)
      write_output(result)
    end

    def write_output(content)
      if options[:output]
        safe_path = validate_output_path(options[:output])
        File.write(safe_path, content)
        say "Output written to: #{safe_path}", :green
      else
        puts content
      end
    end

    def write_json_output(report)
      safe_path = validate_output_path(options[:output])
      File.write(safe_path, report.to_json)
      say "\nReport saved to: #{safe_path}", :green
    end

    def fetch_all_properties(client, searches, city)
      all = []
      seen = Set.new

      searches.each do |query|
        say "  Searching: #{query}...", :cyan
        results = client.search(query, city: city)
        results.each do |prop|
          next if seen.include?(prop.folio)

          seen << prop.folio
          all << prop
        end
      end

      all
    end
  end
end
