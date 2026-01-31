# BCPA

A Ruby CLI for querying the Broward County Property Appraiser (BCPA) API.

## Installation

```bash
gem install bcpa
```

Or clone and install locally:

```bash
git clone https://github.com/joshRpowell/bcpa
cd bcpa
bundle install
bundle exec rake install
```

## Usage

### Search Properties

Search by address or owner name:

```bash
bcpa search "9703 N NEW RIVER CANAL"
bcpa search "SMITH, JOHN"
bcpa search "MOCKINGBIRD LN" --city PL
```

### Lookup by Folio

Get property details by folio number:

```bash
bcpa folio 504108BD0010
```

### Output Formats

Export results as JSON, CSV, or table (default):

```bash
bcpa search "MOCKINGBIRD" --format json
bcpa search "MOCKINGBIRD" --format csv
bcpa search "MOCKINGBIRD" --format table
```

Save to file:

```bash
bcpa search "MOCKINGBIRD" --format csv --output results.csv
bcpa folio 504108BD0010 --format json --output property.json
```

## Advanced: Cross-Reference (Optional)

For HOA managers or property managers who maintain a list of unit owners, the `crossref` command compares your records against BCPA data to identify discrepancies.

```bash
bcpa crossref unit-owners.yaml
bcpa crossref unit-owners.yaml --format csv --output discrepancies.csv
```

The YAML file should have this structure:

```yaml
units:
  - unit: 100
    owner: "SMITH, JOHN"
  - unit: 101
    owner: "JONES, JANE"
```

The report shows matches, discrepancies (different owner names), and units not found in BCPA records.

## Development

```bash
git clone https://github.com/joshRpowell/bcpa
cd bcpa
bundle install
bundle exec rspec
```

## License

MIT License. See [LICENSE](LICENSE) for details.
