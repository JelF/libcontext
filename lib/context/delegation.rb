class Context
  module Delegation
    def delegate(*args, to:, prefix: false)
      target = case to
               when Symbol
                 -> { send(to) }
               when Proc
                 to
               else
                 -> { to }
               end

      args.each do |arg|
        method_name = prefix ? :"#{prefix}_#{arg}" : arg
        define_method(method_name) do |*x, &block|
          instance_exec(&target).public_send(arg, *x, &block)
        end
      end
    end
  end
end
