class AuthorizedToken
  prepend SimpleCommand
  attr_accessor :token

  def initialize(token)
    @token = token
  end

  def call
    slug = JsonWebToken.decode(token)[:slug]
    User.find(slug)
  end
end
