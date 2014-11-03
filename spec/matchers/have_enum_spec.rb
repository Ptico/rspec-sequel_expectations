require 'spec_helper'

describe RSpec::Matchers::Sequel::HaveEnum do
  before :all do
    @enum_name = Faker::Lorem.word
    @values = %w(admin manager user inspector)
    DB.create_enum(@enum_name, @values)
  end

  after :all do
    DB.drop_enum(@enum_name)
  end

  describe '#have_enum' do 
    it 'return true if enum exists' do 
      expect(DB).to have_enum(@enum_name)
    end

    it 'return false if enum does not exists' do 
      expect(DB).to_not have_enum(@enum_name + "1")
    end
  end

  describe '#with_values' do

    it 'returns true if enum have exactly that values' do
      expect(DB).to have_enum(@enum_name).with_values(@values) 
    end

    it 'returns false if enum values differ' do
      expect(DB).not_to have_enum(@enum_name).with_values(@values.dup.push "something_new" ) 
    end
  end
end
