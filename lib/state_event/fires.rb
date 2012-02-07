module StateEvent
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
 
    module ClassMethods
      def aasm_state_fires(state, opts)
        aasm_state state  # define the state
        
        if_name = :"state_event_if_#{state}_changed"
        event_type = opts[:event_type] ? opts[:event_type] : "#{self.name.underscore}_#{state}"

        define_method(if_name) do
          return false unless state_changed?
          return false if try(:suppress_state_events?)
          send(:"#{state}?")
        end

        opts[:subject] = :self unless opts.has_key?(:subject)
 
        method_name = :"fire_#{event_type}_after_save"
        define_method(method_name) do
          create_options = [:actor, :observer, :subject, :secondary_subject, :private, :admin, :city, :private_runner].inject({}) do |memo, sym|
            case opts[sym]
            when :self
              memo[sym] = self
            when true
              memo[sym] = true
            when false
              memo[sym] = false
            else
              memo[sym] = send(opts[sym]) if opts[sym]
            end
            memo
          end
          create_options[:event_type] = event_type.to_s
 
          created_event = ::StateEvent::Config.event_class.create!(create_options)

          # callback if there is another one
          if opts.has_key?(:callback)
            cb = opts[:callback]
            if method(cb).arity == 1
              send(cb, created_event)
            else
              send(cb)
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

        update_attr = :state_changed_at
        send("before_save", "update_#{update_attr}", :if => :state_changed?)
        define_method("update_#{update_attr}") do
          send("#{update_attr}=", Time.now) if has_attribute?(update_attr)
          true
        end
      end
    end
  end
end
