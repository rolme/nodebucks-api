class JsonWebToken
  class << self
    def encode(payload, exp = 1.year.from_now)
      # set token expiration time
      payload[:exp] = exp.to_i

       # this encodes the user data(payload) with our secret key
      JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end

    def decode(token)
      #decodes the token to get user data (payload)
      body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      HashWithIndifferentAccess.new body

    # raise custom error to be handled by custom handler
    rescue JWT::ExpiredSignature, JWT::VerificationError => e
      raise ExceptionHandler::ExpiredSignature, e.message
    rescue JWT::DecodeError, JWT::VerificationError => e
      raise ExceptionHandler::DecodeError, e.message
    end
  end
end
