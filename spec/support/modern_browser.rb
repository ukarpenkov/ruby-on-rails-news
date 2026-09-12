# frozen_string_literal: true

# Rails 8 blocks old browsers. Tests send a modern Chrome user-agent.
RSpec.configure do |config|
  config.before(:each, type: :controller) do
    request.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
  end
end
