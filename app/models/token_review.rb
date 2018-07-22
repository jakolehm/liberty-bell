# frozen_string_literal: true

class TokenReview < Dry::Struct::Value
  API_VERSION = "authentication.k8s.io/v1beta1"

  class User < Dry::Struct::Value
    attribute :username, Types::Strict::String
    attribute :uid, Types::Strict::String
    attribute :groups, Types::Strict::Array.of(Types::Strict::String)
  end

  class Status < Dry::Struct::Value
    attribute :authenticated, Types::Strict::Bool
    attribute :user, User.meta(omittable: true)
  end

  attribute :status, Status
end
