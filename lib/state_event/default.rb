module StateEvent
  module Default
    def self.included(klass)
      klass.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def default_aasm_event
        Util.default_event(self, {})        
      end
      
      def default_aasm_prefix
        val = self.class.respond_to?(:model_name) ? self.class.model_name : self.class.name
        val.to_s.underscore
      end
      
      def default_aasm_class
        Config.event_class
      end
    end
  end
end
