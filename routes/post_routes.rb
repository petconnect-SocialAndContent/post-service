require_relative '../models/post'

# Swagger setup
class PostRoutes < Sinatra::Base
  before do
    content_type 'application/json'
  end

  # POST /posts
  post '/posts' do
    begin
      data = JSON.parse(request.body.read)

      # Simple validation
      halt 400, { error: 'Missing user_id or content' }.to_json unless data['user_id'] && data['content']

      post = Post.new(user_id: data['user_id'], content: data['content'])
      result = POSTS_COLLECTION.insert_one(post.to_document)

      LOGGER.info("New post created: #{result.inserted_id}")

      status 201
      { message: 'Post created', post_id: result.inserted_id.to_s }.to_json

    rescue => e
      LOGGER.error("Error creating post: #{e.message}")
      halt 500, { error: 'Internal server error' }.to_json
    end
  end

  # GET /posts
  get '/posts' do
    begin
      posts = POSTS_COLLECTION.find.limit(10).map do |doc|
        {
          id: doc[:_id].to_s,
          user_id: doc[:user_id],
          content: doc[:content],
          created_at: doc[:created_at]
        }
      end

      posts.to_json
    rescue => e
      LOGGER.error("Error fetching posts: #{e.message}")
      halt 500, { error: 'Internal server error' }.to_json
    end
  end
end
