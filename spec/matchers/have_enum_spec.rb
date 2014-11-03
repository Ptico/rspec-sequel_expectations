require 'spec_helper'

describe RSpec::Matchers::Sequel::HaveEnum do
  before :all do
    @enum_name = Faker::Lorem.word
    DB.create_enum(@enum_name, %w(admin manager user inspector))
  end

  after :all do
    DB.drop_enum(@enum_name)
  end

  describe '#validate_existence_of_enum' do 
    it 'return true if enum exists' do 
      expect(DB).to have_enum(@enum_name)
    end

    it 'return false if enum does not exists' do 
      expect(DB).to_not have_enum(@enum_name + "1")
    end
  end
end
