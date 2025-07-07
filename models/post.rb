class Post
  attr_accessor :user_id, :content, :created_at

  def initialize(user_id:, content:)
    @user_id = user_id
    @content = content
    @created_at = Time.now
  end

  def to_document
    {
      user_id: @user_id,
      content: @content,
      created_at: @created_at
    }
  end
end
