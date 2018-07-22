# frozen_string_literal: true

require_relative '../authenticate/command'

module Gitlab
  class Authenticate < Authenticate::Command

    GITLAB_API = ENV.fetch('GITLAB_API') { 'https://gitlab.com/api/v4' }

    class GitlabError < ::Authenticate::Error
    end

    def execute
      userdata = fetch_user
      groups = fetch_groups

      TokenReview.new(
        status: {
          authenticated: true,
          user: {
            username: userdata['username'],
            uid: userdata['id'].to_s,
            groups: groups
          }
        }
      )
    rescue GitlabError => e
      logger.error "gitlab error - #{e.message} with token #{spec[:token][0..5]}..."
      TokenReview.new(
        status: {
          authenticated: false
        }
      )
    end

    # @return [Hash]
    def fetch_user
      resp = http.get(gitlab_url("/user"))
      if resp.code == 200
        JSON.parse(
          resp.body
        )
      else
        raise GitlabError.new(resp.reason)
      end
    end

    # @return [Array<String>]
    def fetch_groups
      resp = http.get(gitlab_url("/groups"))
      if resp.code == 200
        groups = JSON.parse(resp.body)
        groups.map { |group|
          "#{group['full_path']}"
        }
      else
        raise GitlabError.new(resp.reason)
      end
    end

    def http
      HTTP.headers(
        'Accept' => 'application/json',
        'Private-Token' => spec[:token]
      )
    end

    def gitlab_url(path)
      "#{GITLAB_API}#{path}"
    end
  end
end
