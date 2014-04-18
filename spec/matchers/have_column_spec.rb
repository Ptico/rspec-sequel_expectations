require 'spec_helper'

describe RSpec::Matchers::Sequel::HaveColumn do
  before :all do
    DB.create_table(:users) do
      column :full_name, String
      column :age, Integer, default: 18, null: false
    end
  end

  after :all do
    DB.drop_table(:users)
  end

  let(:table) { :users }

  let(:result) { matcher.matches?(table) }

  describe 'column exists' do
    context 'when exists' do
      let(:matcher) { have_column(:full_name) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "full_name"')
      end
    end

    context 'column not exists' do
      let(:matcher) { have_column(:abyrvalg) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but users does not have a column named "abyrvalg")
      end

      it 'should set negative error message' do
        expect { result }.to change {
          matcher.failure_message_when_negated
        }.to("did not expect users to #{matcher.description}")
      end
    end
  end

  describe 'column type' do
    context 'when correct type' do
      [String, :string, 'string', 'varchar(255)'].each do |type|
        context "with #{type}" do
          let(:matcher) { have_column(:full_name).of_type(type) }

          it 'should success' do
            expect(result).to be(true)
          end

          it 'should have description' do
            expect(matcher.description).to eql %(have column named "full_name" of type #{type})
          end
        end
      end
    end

    context 'when incorrect type' do
      let(:matcher) { have_column(:full_name).of_type(Integer) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but it have type [string, varchar(255)])
      end

      it 'should set negative error message' do
        expect { result }.to change {
          matcher.failure_message_when_negated
        }.to %(did not expect users to #{matcher.description})
      end
    end
  end

  describe 'with_default' do
    context 'when match' do
      let(:matcher) { have_column(:age).with_default(18) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "age" with default value "18"')
      end
    end

    context 'when did not match' do
      let(:matcher) { have_column(:age).with_default(2) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "age" with default value "2"')
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but it has default value "18")
      end
    end
  end

  describe 'allow_null' do
    context 'when match' do
      let(:matcher) { have_column(:full_name).allow_null }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "full_name" allowing null')
      end
    end

    context 'when did not match' do
      let(:matcher) { have_column(:age).allow_null }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "age" allowing null')
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but it does not allow null)
      end
    end
  end

  describe 'not_null' do
    context 'when match' do
      let(:matcher) { have_column(:age).not_null }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "age" not allowing null')
      end
    end

    context 'when did not match' do
      let(:matcher) { have_column(:full_name).not_null }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have column named "full_name" not allowing null')
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but it allow null)
      end
    end
  end


end
