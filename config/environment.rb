require 'sinatra'
require 'mongo'
require 'dotenv/load'
require 'logger'

# Mongo client
DB_CLIENT = Mongo::Client.new(ENV['MONGO_URI'], server_selection_timeout: 5)
POSTS_COLLECTION = DB_CLIENT[:posts]

# Logger
LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO
