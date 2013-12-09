module StateEvent
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
 
    module InstanceMethods
      def suppress_state_events
        @suppress_state_events = true
      end
      
      def enable_state_events
        @suppress_state_events = false
      end
      
      def suppress_state_events?
        !!@suppress_state_events
      end
    end
 
    module ClassMethods
      def aasm_state_fires(state, opts)
        unless method_defined?(:suppress_state_events?)
          send(:include, InstanceMethods)
        end
        
        aasm_state state  # define the state
        
        callback = opts.delete(:callback)
        
        if_name = "state_event_if_#{state}_changed"
        define_method(if_name) do
          return false unless state_changed?
          return false if try(:suppress_state_events?)
          send("#{state}?")
        end
        
        method_name = "fire_#{state}_state_after_commit"
        define_method(method_name) do
          created_event = Util.create_event(self, opts, state)

          # callback if there is one
          if callback
            if method(callback).arity == 1
              send(callback, created_event)
            else
              send(callback)
            end
          end

          true
        end
 
        after_commit method_name, :if => if_name
      end
    end
  end
end
