# frozen_string_literal: true

require_relative '../authenticate/command'

module Github
  class Authenticate < Authenticate::Command
    GITHUB_API = 'https://api.github.com'.freeze

    class GithubError < ::Authenticate::Error
    end

    def execute
      userdata = fetch_user
      groups = fetch_groups

      TokenReview.new(
        status: {
          authenticated: true,
          user: {
            username: userdata['login'],
            uid: userdata['id'].to_s,
            groups: groups
          }
        }
      )
    rescue GithubError => e
      logger.error "github error - #{e.message} with token #{spec[:token][0..5]}..."
      TokenReview.new(
        status: {
          authenticated: false
        }
      )
    end

    # @return [Hash]
    def fetch_user
      resp = HTTP.headers(
        'Accept' => 'application/json',
        'Authorization' => "token #{spec[:token]}"
      ).get(gh_url("/user"))
      if resp.code == 200
        JSON.parse(
          resp.body
        )
      else
        raise GithubError.new(resp.reason)
      end
    end

    # @return [Array<String>]
    def fetch_groups
      resp = HTTP.headers(
        'Accept' => 'application/vnd.github.hellcat-preview+json',
        'Authorization' => "token #{spec[:token]}"
      ).get(gh_url("/user/teams"))
      if resp.code == 200
        teams = JSON.parse(resp.body)
        teams.map { |team|
          "#{team.dig('organization', 'login')}/#{team['slug']}"
        }
      else
        raise GithubError.new(resp.reason)
      end
    end

    def gh_url(path)
      "#{GITHUB_API}#{path}"
    end
  end
end
