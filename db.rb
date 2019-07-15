require 'sequelize'

ROOT_DIR = File.expand_path(__dir__).freeze
CONFIG_FILE = 'config/database.yml'.freeze

unless File.exist?(File.join(ROOT_DIR, CONFIG_FILE))
  abort 'File `config/database.yml` does not exist. Please create it.'
end

Sequelize.configure do
  root        ROOT_DIR
  config_file CONFIG_FILE
end

Sequelize.setup(ENV['DB_ENV'] || 'test')

DB = Sequelize.connection

DB.extension(:pg_enum)
