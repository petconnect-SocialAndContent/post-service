require 'sinatra'
require 'mongo'
require 'json'
require 'jwt'
require 'dotenv/load'

class App < Sinatra::Base
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
        @current_user = payload[0]
      rescue JWT::DecodeError => e
        halt 401, { error: "Invalid token: #{e.message}" }.to_json
      end
    end
  end

  # Rutas
  get '/api/v1/posts' do
    content_type :json
    posts = posts_collection.find.sort(created_at: -1).limit(20).map do |post|
      {
        _id: post[:_id].to_s,
        user_id: post[:user_id],
        title: post[:title],
        content: post[:content],
        created_at: post[:created_at]
      }
    end
    posts.to_json
  end

  post '/api/v1/posts' do
    content_type :json
    protected!

    data = JSON.parse(request.body.read)
    title = data['title']
    content = data['content']

    new_post = {
      user_id: @current_user['user_id'],
      title: title,
      content: content,
      created_at: Time.now.utc
    }

    result = posts_collection.insert_one(new_post)
    halt 500, { error: 'Failed to create post' }.to_json unless result.n == 1

    { message: 'Post created', post_id: result.inserted_id.to_s }.to_json
  end
end

# Para ejecución directa con 'ruby app.rb'
run! if __FILE__ == $0