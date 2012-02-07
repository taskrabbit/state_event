module StateEvent
  module Event
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
 
    module ClassMethods
      def acts_as_state_event(opts={})
        ::StateEvent::Config.event_class = self
      end
    end
  end
end
