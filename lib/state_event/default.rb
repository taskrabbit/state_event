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
        val = nil
        val = self.override_default_aasm_prefix if self.respond_to?(:override_default_aasm_prefix)
        val ||= self.class.respond_to?(:model_name) ? self.class.model_name : self.class.name
        val.to_s.underscore
      end
      
      def default_aasm_class
        val = nil
        val = self.override_default_aasm_class if self.respond_to?(:override_default_aasm_class)
        val ||= Config.event_class
        val
      end
    end
  end
end
