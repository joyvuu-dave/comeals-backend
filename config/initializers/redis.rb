$redis = Redis.new(url: ENV["REDIS_TLS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
