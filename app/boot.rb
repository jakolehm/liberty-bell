# frozen_string_literal: true

require 'json'
require 'roda'
require 'mutations'
require 'json_serializer'
require 'http'

def require_glob(glob)
  Dir.glob(glob).sort.each do |path|
    require path
  end
end

require_glob __dir__ + '/mixins/*.rb'
require_glob __dir__ + '/models/*.rb'
require_glob __dir__ + '/commands/**/*.rb'
require_glob __dir__ + '/serializers/**/*.rb'
