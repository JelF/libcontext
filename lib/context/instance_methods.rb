require 'context/delegation'
require 'context/query'

class Context
  module InstanceMethods
    extend Delegation
    delegate :set, :pluck, to: -> { Query.new(self) }

    def initialize
      self.variables = {}
      self.variables_set = [Set.new]
    end

    def [](key)
      key = key.to_sym
      return nil unless variables.key?(key)
      variables[key].last
    end

    def []=(key, value)
      key = key.to_sym
      variables[key] ||= []
      variables[key].pop if variable_set?(key)
      variables[key] << value
      variables_set.last << key
      value
    end

    private

    attr_accessor :variables
    attr_accessor :variables_set

    def undef_variable(key)
      variables_set.last.delete(key)
      variables[key].pop
    end

    def release!(query, block)
      variables_set.push(Set.new)

      query.sets.each do |key, value|
        key = key.to_sym
        self[key] = value
      end

      block.call

      result = []

      query.plucks.each { |key| result << (undef_variable(key) if variable_set?(key)) }

      case result.length
      when 0 then nil
      when 1 then result.first
      else result
      end
    ensure
      variables_set.pop.each { |key| variables[key].pop }
    end

    def variable_set?(key)
      variables_set.last.include?(key)
    end
  end
end
