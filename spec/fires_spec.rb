require 'spec_helper'

class TestEvent < ActiveRecord::BaseWithoutTable
  acts_as_state_event
end

class TestFires < ActiveRecord::BaseWithoutTable
  column :state, :string
  
  acts_as_aasm_object :actor => :foo
  
  aasm_initial_state :first
  aasm_state_fires :first, :actor => :foo
  
  def foo
    "bar"
  end
end

describe "Fires Event Creation" do
  it "should call to create a TestEvent" do
    test = TestFires.new
    TestEvent.expects(:create!).with(:event_type => 'test_fires_first', :subject => test, :actor => "bar")
    test.save.should be_true
  end
end
