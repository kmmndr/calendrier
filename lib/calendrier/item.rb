module Calendrier
  class Item
    attr_accessor :obj, :options

    def initialize(obj, options = {})
      self.obj = obj
      self.options = options
    end

    def method_missing(method, *args, &block)
      ret = nil

      unless obj.nil?
        if !options[method].nil?
          if options[method].is_a?(Symbol)
            ret = obj.send(options[method])
          else
            ret = options[method]
          end
        elsif options.include?(:field)
          ret = obj.send(options[:field]).send(method)
        elsif obj.respond_to?(method)
          ret = obj.send(method)
        end
      end

      ret
    end

    def respond_to?(method, include_private = false)
      ret = true

      begin
        self.send(method)
      rescue NoMethodError
        ret = false
      end

      ret
    end

  end
end
