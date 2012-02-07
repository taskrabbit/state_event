module StateEvent
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
 
    module ClassMethods
      def aasm_state_fires(state, opts)
        aasm_state state  # define the state
        
        if_name = :"state_event_if_#{state}_changed"
        define_method(if_name) do
          return false unless state_changed?
          return false if try(:suppress_state_events?)
          send(:"#{state}?")
        end

        opts[:subject] ||= :self
        callback = opts.delete(:callback)
        event_type = opts.delete(:event_type)
        event_type ||= "#{self.name.underscore}_#{state}"
        
 
        method_name = :"fire_#{event_type}_after_save"
        define_method(method_name) do
          create_options = {}
          opts.each do |key, value|
            sym = key.to_sym
            case value
            when :self
              create_options[sym] = self
            when true
              create_options[sym] = true
            when false
              create_options[sym] = false
            when nil
              create_options[sym] = nil
            else
              create_options[sym] = send(value)
            end
          end
          create_options[:event_type] = event_type
          
          created_event = ::StateEvent::Config.event_class.create!(create_options)

          # callback if there is another one
          if callback
            if method(callback).arity == 1
              send(callback, created_event)
            else
              send(callback)
            end
          end

          true
        end
 
        after_save method_name, :if => if_name
      end
      
      def acts_as_state_event(opts={})
        ::StateEvent::Config.event_class = self
      end
      
      def acts_as_aasm_object(opts={})
        unless opts.has_key?(:no_state)
          include AASM
          aasm_column :state
        end

        define_method(:suppress_state_events) do
          @suppress_state_events = true
        end
        define_method(:enable_state_events) do
          @suppress_state_events = false
        end
        define_method(:suppress_state_events?) do
          !!@suppress_state_events
        end

        if opts.has_key?(:time)
          method_name = :"default_event_time"
          define_method(method_name) do
            return send(opts[:time])
          end
        end
        
        if opts.has_key?(:actor)
          method_name = :"default_event_actor"
          define_method(method_name) do
            return self if opts[:actor] == :self
            return nil if opts[:actor] == false
            return send(opts[:actor])
          end
        end

        send("before_save", "update_dynamic_state_changed_at", :if => :state_changed?)
        define_method("update_dynamic_state_changed_at") do
          time = Time.now
          ["state_changed_at", "#{state}_state_at"].each do |attribute|
            send("#{attribute}=", time) if has_attribute?(attribute)
          end
          true
        end
      end
    end
  end
end
