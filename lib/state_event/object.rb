module StateEvent
  module Object
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
    
    module InstanceMethods
      def create_aasm_event(state, options={})
        hash = self.class.default_aasm_options.symbolize_keys.merge(options.symbolize_keys)
        hash.delete(:time)
        Util.create_event(self, hash, state)
      end
      
      def build_aasm_event(state, options={})
        hash = self.class.default_aasm_options.symbolize_keys.merge(options.symbolize_keys)
        hash.delete(:time)
        Util.build_event(self, hash, state)
      end
      
      def default_aasm_event
        Util.default_event(self, self.class.default_aasm_options.symbolize_keys)        
      end
      
      protected
      
      def update_dynamic_state_changed_at
        time = Time.now
        ["state_changed_at", "#{state}_state_at"].each do |attribute|
          send("#{attribute}=", time) if has_attribute?(attribute)
        end
        true
      end
      
      def aasm_state_changed?
        state_changed?
      end
    end
 
    module ClassMethods
      def default_aasm_options
        @default_aasm_options || {}
      end
      def acts_as_aasm_object(initial=nil, opts={})
        if initial and not initial == :none
          include AASM
          aasm_column :state
          aasm_initial_state initial unless initial == :defer
          before_save :update_dynamic_state_changed_at, :if => :aasm_state_changed?
        end
        
        if prefix = opts.delete(:prefix)
          define_method(:default_aasm_prefix) do
            prefix
          end
        end
        
        @default_aasm_options = opts
        include InstanceMethods
      end
    end
  end
end
