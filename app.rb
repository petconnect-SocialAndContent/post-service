# app.rb
require 'sinatra'
require 'mongo'
require 'json'
require 'jwt'
require 'dotenv/load' # <-- carga .env automáticamente

# Configurar MongoDB
mongo_uri = ENV['MONGODB_URI'] || 'mongodb://localhost:27017/post_service'
client = Mongo::Client.new(mongo_uri)
db = client.database
posts_collection = db[:posts]

# JWT Secret
JWT_SECRET = ENV['JWT_SECRET'] || 'supersecreto123diegopetconnect456'

# Middleware CORS
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
end

# OPTIONS preflight
options '*' do
  200
end

# Helper: verificar JWT
helpers do
  def protected!
    token = request.env["HTTP_AUTHORIZATION"]&.split(' ')&.last
    halt 401, { error: 'Missing token' }.to_json unless token
    begin
      payload = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })
      @current_user = payload[0] # Puedes usarlo en tus rutas
    rescue JWT::DecodeError => e
      halt 401, { error: "Invalid token: #{e.message}" }.to_json
    end
  end
end

# Rutas
get '/api/posts' do
  content_type :json
  posts = posts_collection.find.to_a.map do |post|
    {
      id: post[:_id].to_s,
      title: post[:title],
      content: post[:content],
      created_at: post[:created_at]
    }
  end
  posts.to_json
end

post '/api/posts' do
  content_type :json
  protected! # requiere JWT

  payload = JSON.parse(request.body.read)

  if payload['title'].to_s.strip.empty? || payload['content'].to_s.strip.empty?
    status 400
    return { error: 'Title and content are required' }.to_json
  end

  result = posts_collection.insert_one({
    user_id: @current_user['id'],
    title: payload['title'],
    content: payload['content'],
    created_at: Time.now
  })

  { id: result.inserted_id.to_s, message: 'Post created' }.to_json
end

# Documentación
get '/api-docs' do
  <<-HTML
    <h1>Post Service API</h1>
    <ul>
      <li>GET /api/posts</li>
      <li>POST /api/posts (requires JWT)</li>
    </ul>
  HTML
end

# Bind en Docker
set :bind, '0.0.0.0'
set :port, ENV.fetch('PORT', 3006)
