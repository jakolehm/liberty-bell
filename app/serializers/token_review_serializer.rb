# frozen_string_literal: true

class TokenReviewSerializer < JsonSerializer
  class UserSerializer < JsonSerializer
    attribute :username
    attribute :uid
    attribute :groups
  end
  
  class StatusSerializer < JsonSerializer
    attribute :authenticated
    attribute :user, UserSerializer
  end

  attribute :apiVersion
  attribute :kind
  attribute :status, StatusSerializer

  def apiVersion
    TokenReview::API_VERSION
  end

  def kind
    TokenReview.name
  end

  def as_json
    hash = to_hash
    hash[:status].delete(:user) unless hash.dig(:status, :user)

    hash
  end
end
