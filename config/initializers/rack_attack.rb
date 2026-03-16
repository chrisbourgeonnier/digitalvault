class Rack::Attack
  # Use memory store for rate limiting to avoid database dependency
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Enable logging
  self.throttled_response_retry_after_header = true

  # Log blocked requests
  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled #{req.path} from #{req.ip}"
  end

  # Throttle all requests by IP (60rpm)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle login attempts by IP address
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email address
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      # Normalize email to prevent case-sensitivity bypass
      req.params["user"]["email"].to_s.downcase.gsub(/\s+/, "") if req.params.dig("user", "email").present?
    end
  end

  # Throttle password reset requests
  throttle("password_resets/ip", limit: 3, period: 5.minutes) do |req|
    if req.path == "/users/password" && req.post?
      req.ip
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    headers = {
      "RateLimit-Limit" => match_data[:limit].to_s,
      "RateLimit-Remaining" => "0",
      "RateLimit-Reset" => (now + (match_data[:period] - now % match_data[:period])).to_s
    }

    [ 429, headers, [ "Too many requests. Please try again later.\n" ] ]
  end
end
