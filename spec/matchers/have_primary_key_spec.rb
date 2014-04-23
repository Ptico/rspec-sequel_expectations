require 'spec_helper'

describe RSpec::Matchers::Sequel::HavePrimaryKey do
  before :all do
    DB.create_table(:companies) do
      column :id, Integer
      column :country_id, Integer

      primary_key [:id, :country_id], name: :companies_pk
    end

    DB.create_table(:users) do
      primary_key :id
    end

    DB.create_table(:sessions) do
      column :session_id, Integer
    end
  end

  after :all do
    DB.drop_table(:companies)
    DB.drop_table(:users)
    DB.drop_table(:sessions)
  end

  let(:result) { matcher.matches?(table) }

  describe 'have_primary_key' do
    context 'single key' do
      let(:table) { :users }

      context 'when match' do
        let(:matcher) { have_primary_key(:id) }

        it 'should success' do
          expect(result).to be(true)
        end

        it 'should have description' do
          expect(matcher.description).to eql('have primary key "id"')
        end
      end

      context 'when did not match' do
        let(:matcher) { have_primary_key(:user_id) }

        it 'should fail' do
          expect(result).to be(false)
        end

        it 'should set error message' do
          expect { result }.to change {
            matcher.failure_message
          }.to %(expected users to #{matcher.description} but users have primary key "id")
        end

        it 'should set negative error message' do
          expect { result }.to change {
            matcher.failure_message_when_negated
          }.to("did not expect users to #{matcher.description}")
        end
      end

      context 'when without keys' do
        let(:matcher) { have_primary_key(:user_id) }
        let(:table)   { :sessions }

        it 'should fail' do
          expect(result).to be(false)
        end

        it 'should set error message' do
          expect { result }.to change {
            matcher.failure_message
          }.to %(expected sessions to #{matcher.description} but sessions have no primary keys)
        end

        it 'should set negative error message' do
          expect { result }.to change {
            matcher.failure_message_when_negated
          }.to("did not expect sessions to #{matcher.description}")
        end
      end
    end

    context 'compound key' do
      let(:table) { :companies }

      context 'when match' do
        context 'single test' do
          let(:matcher) { have_primary_key(:country_id) }

          it 'should success' do
            expect(result).to be(true)
          end

          it 'should have description' do
            expect(matcher.description).to eql('have primary key "country_id"')
          end
        end

        context 'compound test' do
          let(:matcher) { have_primary_keys(:id, :country_id) }

          it 'should success' do
            expect(result).to be(true)
          end

          it 'should have description' do
            expect(matcher.description).to eql('have primary keys [:id, :country_id]')
          end
        end

      end

      context 'when did not match' do
        let(:matcher) { have_primary_keys(:id, :city_id) }

        it 'should fail' do
          expect(result).to be(false)
        end

        it 'should set error message' do
          expect { result }.to change {
            matcher.failure_message
          }.to %(expected companies to #{matcher.description} but companies have primary keys [:id, :country_id])
        end

        it 'should set negative error message' do
          expect { result }.to change {
            matcher.failure_message_when_negated
          }.to("did not expect companies to #{matcher.description}")
        end
      end

      context 'when without keys' do
        let(:matcher) { have_primary_keys(:user_id, :id) }
        let(:table)   { :sessions }

        it 'should fail' do
          expect(result).to be(false)
        end

        it 'should set error message' do
          expect { result }.to change {
            matcher.failure_message
          }.to %(expected sessions to #{matcher.description} but sessions have no primary keys)
        end

      end
    end
  end

end
