require 'specr'
require 'active_support/inflector'
require './testData'

Specr.configure do |config|
  config.root_url = ENV['ROOT_URL'] || 'http://localhost:9010'
  config.default_headers = {
    'Accept' => 'application/vnd.api+json;revision=1',
    'Content-Type' => 'application/vnd.api+json',
    'X-Api-Key' => ENV['API_KEY'] || 'Company-KEY',
    'Authorization' => "Bearer #{ENV['API_TOKEN']}"
  }
end

# module defined for retaining values between scenarios
module Local
  class << self
    attr_accessor :client
  end
  class GlobalStore
    attr_reader :storage
    def initialize
      @storage = {}
    end
  end
end

Local.client = Local::GlobalStore.new
