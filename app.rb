# app.rb
require 'sinatra'
require 'mongo'
require 'json'

# Configurar MongoDB
client = Mongo::Client.new(ENV['MONGODB_URI'] || 'mongodb://post-mongo:27017/post_service')
db = client.database
posts_collection = db[:posts]

# CORS
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
end

# OPTIONS preflight
options '*' do
  200
end

# RUTAS
get '/posts' do
  content_type :json
  posts = posts_collection.find.to_a.map { |post| post.transform_keys(&:to_s) }
  posts.to_json
end

post '/posts' do
  content_type :json
  payload = JSON.parse(request.body.read)
  
  # Validación simple
  if payload['title'].to_s.strip.empty? || payload['content'].to_s.strip.empty?
    status 400
    return { error: 'Title and content are required' }.to_json
  end

  result = posts_collection.insert_one({
    title: payload['title'],
    content: payload['content'],
    created_at: Time.now
  })

  { id: result.inserted_id.to_s, message: 'Post created' }.to_json
end

# Swagger (placeholder)
get '/api-docs' do
  '<h1>Swagger UI coming soon</h1>'
end

# Bind en Docker
set :bind, '0.0.0.0'
set :port, ENV.fetch('PORT', 3006)
