require "aasm"
require "state_event/version"
require "state_event/fires"


ActiveRecord::Base.send :include, StateEvent::Fires