# frozen_string_literal: true

require_relative './app/boot'

puts "~~~~ LIBERTY BELL - K8s Token Authenticator ~~~~\n\n"

class Server < Roda
  plugin :json
  plugin :json_parser
  plugin :error_handler do |e|
    puts e.message
    puts e.backtrace.join("\n")
    response.status = 500
    {}
  end

  # @param provider [Authenticate::Command]
  # @return [Hash]
  def authenticate_with(provider)
    outcome = provider.run(r.POST)
    if outcome.success?
      TokenReviewSerializer.new(outcome.result).as_json
    else
      response.status = 422
      {}
    end
  end

  route do |r|
    r.on 'github' do
      r.post do
        authenticate_with(Github::Authenticate)
      end
    end

    r.on 'gitlab' do
      r.post do
        authenticate_with(Gitlab::Authenticate)
      end
    end

    r.on 'healthz' do
      r.get do
        { message: 'all ok' }
      end
    end
  end
end