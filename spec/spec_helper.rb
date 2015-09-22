require 'bundler'
Bundler.require(:development)

require 'context'
Dir['../support/*.rb'].each { |x| require_relative(x) }

