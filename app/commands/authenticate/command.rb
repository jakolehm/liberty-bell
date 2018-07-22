# frozen_string_literal: true

require 'http'
require_relative 'error'

module Authenticate
  class Command < Mutations::Command
    include Logging

    required do
      string :apiVersion, in: [TokenReview::API_VERSION]
      string :kind, in: [TokenReview.name]
      hash :spec do
        required do
          string :token
        end
      end
    end
  end
end
