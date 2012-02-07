module StateEvent
  module Util
    extend self
    
    def get_event_hash(object, opts)
      out = {}
      opts.each do |key, value|
        sym = key.to_sym
        case value
        when :self
          out[sym] = object
        when true
          out[sym] = true
        when false
          out[sym] = false
        when nil
          out[sym] = nil
        else
          out[sym] = object.send(value)
        end
      end
      out
    end
    
  end
end