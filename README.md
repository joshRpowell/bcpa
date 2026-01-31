# BCPA

A Ruby CLI for querying the Broward County Property Appraiser (BCPA) API.

## Installation

```bash
gem install bcpa
```

Or add to your Gemfile:

```ruby
gem "bcpa"
```

## Usage

### Search by Address or Owner

```bash
bcpa search "9703 N NEW RIVER CANAL"
bcpa search "SMITH" --city PL
```

### Lookup by Folio Number

```bash
bcpa folio 504108BD0010
```

### Cross-Reference Owners

Compare a YAML file of unit owners against BCPA records:

```bash
bcpa crossref unit-owners.yaml
```

The YAML file should have this structure:

```yaml
units:
  - unit: 100
    owner: "SMITH, JOHN"
    type: villa
  - unit: 101
    owner: "JONES, JANE"
    type: townhome
```

### Output Formats

```bash
bcpa search "MOCKINGBIRD" --format json
bcpa search "MOCKINGBIRD" --format table
bcpa search "MOCKINGBIRD" --format csv
bcpa search "MOCKINGBIRD" --output results.json
```

## Development

```bash
git clone https://github.com/joshuapowell/bcpa
cd bcpa
bundle install
bundle exec rspec
```

## License

MIT License. See [LICENSE](LICENSE) for details.
