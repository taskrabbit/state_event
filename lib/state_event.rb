require "aasm"
require "state_event/version"
require "state_event/util"
require "state_event/config"
require "state_event/object"
require "state_event/event"
require "state_event/fires"

ActiveRecord::Base.send :include, StateEvent::Object
ActiveRecord::Base.send :include, StateEvent::Event
ActiveRecord::Base.send :include, StateEvent::Fires
