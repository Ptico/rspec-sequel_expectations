require 'spec_helper'

describe RSpec::Matchers::Sequel::HaveIndexOn do
  before :all do
    DB.create_table(:users) do
      column :name, String, index: true
      column :login, String, index: true, unique: true
      column :email, String
      column :company_id, Integer
      column :department_id, Integer
      column :created_at, Time

      index :email, unique: true, name: 'users_postbox'
      index [:company_id, :department_id]
    end
  end

  after :all do
    DB.drop_table(:users)
  end

  let(:table) { :users }

  let(:result) { matcher.matches?(table) }

  describe 'have_index_on' do
    context 'single' do
      context 'when exists' do
        let(:matcher) { have_index_on(:name) }

        it 'should success' do
          expect(result).to be(true)
        end

        it 'should have description' do
          expect(matcher.description).to eql('have index on [:name]')
        end
      end

      context 'when not exists' do
        let(:matcher) { have_index_on(:created_at) }

        it 'should fail' do
          expect(result).to be(false)
        end

        it 'should set error message' do
          expect { result }.to change {
            matcher.failure_message
          }.to %(expected users to #{matcher.description} but none exists)
        end

        it 'should set negative error message' do
          expect { result }.to change {
            matcher.failure_message_when_negated
          }.to %(did not expect users to #{matcher.description})
        end
      end
    end

    context 'composite' do
      context 'when exists' do
        let(:matcher) { have_index_on([:company_id, :department_id]) }

        it 'should success' do
          expect(result).to be(true)
        end

        it 'should have description' do
          expect(matcher.description).to eql('have index on [:company_id, :department_id]')
        end
      end

      context 'when not exists' do
        let(:matcher) { have_index_on([:company_id, :email]) }

        it 'should fail' do
          expect(result).to be(false)
        end
      end
    end
  end

  describe 'uniqueness' do
    context 'when single' do
      let(:matcher) { have_unique_index_on(:email) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have unique index on [:email]')
      end
    end

    context 'when have both index and constraint' do
        let(:matcher) { have_unique_index_on(:login) }

        it 'should success' do
          expect(result).to be(true)
        end
    end

    context 'when not unique' do
      let(:matcher) { have_unique_index_on(:name) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but index is non-unique)
      end

      it 'should set negative error message' do
        expect { result }.to change {
          matcher.failure_message_when_negated
        }.to %(did not expect users to #{matcher.description})
      end
    end
  end

  describe 'index name' do
    context 'when match' do
      let(:matcher) { have_unique_index_on(:email).named('users_postbox') }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have unique index on [:email] named "users_postbox"')
      end
    end

    context 'when did not match' do
      let(:matcher) { have_unique_index_on(:email).named('users_email') }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected users to #{matcher.description} but index have name "users_postbox")
      end

      it 'should set negative error message' do
        expect { result }.to change {
          matcher.failure_message_when_negated
        }.to %(did not expect users to #{matcher.description})
      end
    end
  end

end
