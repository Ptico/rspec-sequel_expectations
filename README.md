# Rspec Sequel expectations

RSpec matchers for Sequel which tests database, not model

## Using

```ruby
RSpec.configure do |config|
  config.include RSpec::Matchers::Sequel
end

describe 'companies table' do
  let(:table) { :companies }

  it { expect(table).to have_primary_keys(:id, :city_id) }
  it { expect(table).to have_column(:name).of_type(String).not_null.with_default('') }
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-sequel_expectations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-sequel_expectations

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-sequel_expectations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
