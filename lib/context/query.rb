class Context
  class Query
    attr_accessor :sets
    attr_accessor :plucks

    def initialize(context)
      self.context = context
      self.sets = {}
      self.plucks = Set.new
    end

    def set(**args, &block)
      sets.merge!(args)
      block ? release!(block) : self
    end

    def pluck(*args, &block)
      self.plucks += args
      block ? release!(block) : self
    end

    private

    attr_accessor :context

    def release!(block)
      context.send(:release!, self, block)
    end
  end
end
