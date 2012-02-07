module StateEvent
  module Util
    extend self
    
    def get_event_hash(object, opts)
      out = {}
      opts.each do |key, value|
        sym = key.to_sym
        if value == :self
          out[sym] = object
        elsif value.is_a? Symbol
          out[sym] = object.send(value)
        elsif value.respond_to?(:call)
          out[sym] = value.call(object)
        else
          out[sym] = value
        end
      end
      out
    end
    
  end
end