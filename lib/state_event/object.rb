module StateEvent
  module Object
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
    
    module InstanceMethods
      protected
      
      def update_dynamic_state_changed_at
        time = Time.now
        ["state_changed_at", "#{state}_state_at"].each do |attribute|
          send("#{attribute}=", time) if has_attribute?(attribute)
        end
        true
      end
    end
 
    module ClassMethods
      def acts_as_aasm_object(initial=nil, opts={})
        include AASM
        aasm_column :state
        if initial and not initial == :none
          aasm_initial_state initial
        end

        include InstanceMethods
        before_save :update_dynamic_state_changed_at, :if => :state_changed?
        
        if opts.has_key?(:time)
          method_name = :default_event_time
          define_method(method_name) do
            return send(opts[:time])
          end
        end
        
        if opts.has_key?(:actor)
          method_name = :default_event_actor
          define_method(method_name) do
            return self if opts[:actor] == :self
            return nil if opts[:actor] == false
            return send(opts[:actor])
          end
        end
      end
    end
  end
end
