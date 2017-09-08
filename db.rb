require 'sequelize'

Sequelize.configure do
  root        File.expand_path('.', File.dirname(__FILE__))
  config_file 'config/database.yml'
end

Sequelize.setup(ENV['DB_ENV'] || 'test')

DB = Sequelize.connection

DB.extension(:pg_enum)
