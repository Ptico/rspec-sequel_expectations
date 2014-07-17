require 'spec_helper'

describe RSpec::Matchers::Sequel::ReferTo do
  before :all do
    DB.create_table(:users) do
      column :name, String
    end

    DB.create_table(:posts) do
      column :text, String

      foreign_key :user_id, :users, on_update: :cascade, key: :id
    end
  end

  after :all do
    DB.drop_table(:posts)
    DB.drop_table(:users)
  end

  let(:table) { :posts }

  let(:result) { matcher.matches?(table) }

  describe 'refer_to' do
    context 'when reference exist' do
      let(:matcher) { refer_to(:users) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have reference to "users"')
      end
    end

    context 'when reference not exist' do
      let(:matcher) { refer_to(:blabla) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected "posts" to #{matcher.description} but "posts" does not have a reference to "blabla")
      end

      it 'should set negative error message' do
        expect { result }.to change {
          matcher.failure_message_when_negated
        }.to %(did not expect "posts" to #{matcher.description})
      end
    end
  end

  describe 'from_fk' do
    context 'when foreign key column exist' do
      let(:matcher) { refer_to(:users).from_fk(:user_id) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have reference to "users" with column "user_id"')
      end
    end

    context 'when foreign key column not exist' do
      let(:matcher) { refer_to(:users).from_fk(:blabla_id) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected "posts" to #{matcher.description} but "posts" does not have a foreign key column "blabla_id")
      end
    end
  end

  describe 'with_pk' do
    context 'when primary key column exist' do
      let(:matcher) { refer_to(:users).to_pk(:id) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have reference to "users" with primary key column "id"')
      end
    end

    context 'when primary key column not exist' do
      let(:matcher) { refer_to(:users).to_pk(:blabla) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected "posts" to #{matcher.description} but "users" does not have a primary key column "blabla")
      end
    end
  end

  describe 'on_update' do
    context 'when update action right' do
      let(:matcher) { refer_to(:users).on_update(:cascade) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have reference to "users" with "cascade" action on update')
      end
    end

    context 'when update action wrong' do
      let(:matcher) { refer_to(:users).on_update(:blabla) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected "posts" to #{matcher.description} but reference does not have action "blabla" on update)
      end
    end
  end

  describe 'on_delete' do
    context 'when delete action right' do
      let(:matcher) { refer_to(:users).on_delete(:no_action) }

      it 'should success' do
        expect(result).to be(true)
      end

      it 'should have description' do
        expect(matcher.description).to eql('have reference to "users" with "no_action" action on delete')
      end
    end

    context 'when update action wrong' do
      let(:matcher) { refer_to(:users).on_delete(:blabla) }

      it 'should fail' do
        expect(result).to be(false)
      end

      it 'should set error message' do
        expect { result }.to change {
          matcher.failure_message
        }.to %(expected "posts" to #{matcher.description} but reference does not have action "blabla" on delete)
      end
    end
  end
end
