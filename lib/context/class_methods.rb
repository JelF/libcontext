require 'context/delegation'
require 'context/query'

def Context(&block)
  Context::Query.new(Context.current_context).send(:release!, block)
end

class Context
  module ClassMethods
    extend Delegation

    delegate :[], :[]=, :set, :pluck,
             to: :current_context

    def current_context
      Thread.current[:context] ||= Context.new
    end
  end
end
