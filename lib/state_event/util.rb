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
      out[:subject] ||= object
      out
    end
    
    def create_event(object, opts, state)
      out = build_event(object, opts, state)
      out.save
      out
    end
    
    def build_event(object, opts, state)
      build_options = get_event_hash(object, opts)
      build_options[:event_type] ||= "#{object.class.model_name.underscore}_#{state}"
      Config.event_class.new(build_options)
    end
    
    def default_event(object, opts)
      build_options = get_event_hash(object, opts)
      build_options[:event_type] = "#{object.class.model_name.underscore}"
      
      val = build_options.delete(:time)
      out = Config.event_class.new(build_options)
      
      if out.has_attribute?(:created_at)
        out.created_at = val
        out.created_at ||= object.created_at if object.has_attribute?(:created_at)
      end
      
      if out.has_attribute?(:udpated_at)
        out.updated_at = val
        out.updated_at ||= object.updated_at if object.has_attribute?(:updated_at)
      end

      out
    end
    
    
    
  end
end