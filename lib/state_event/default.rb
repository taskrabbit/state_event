module StateEvent
  module Default
    def self.included(klass)
      klass.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def default_aasm_event
        Util.default_event(self, {})        
      end
    end
  end
end
