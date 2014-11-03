require 'spec_helper'

describe RSpec::Matchers::Sequel::HaveEnum do
  before :all do
    @enum_name = Faker::Lorem.word
    @types = %w(admin manager user inspector)
    DB.create_enum(@enum_name, @types)
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

  describe '#with_types' do 
    it 'accept array of fields as argument' do
      expect{described_class.new.with_types(1)}.to raise_error(ArgumentError) 
    end

    it 'returns true if enum have exactly that values' do
      expect(DB).to have_enum(@enum_name).with_types(@types) 
    end

    it 'returns false if enum values differ' do
      expect(DB).not_to have_enum(@enum_name).with_types(@types.push "something_new" ) 
    end
  end
end
