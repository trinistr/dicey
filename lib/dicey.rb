# frozen_string_literal: true

Dir["#{__dir__}/dicey/**/*.rb"].each { require _1 }

module Dicey
  class Error < StandardError; end
end
