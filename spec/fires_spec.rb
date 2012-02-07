require 'spec_helper'

class TestEvent < ActiveRecord::BaseWithoutTable
  acts_as_state_event
  column :actor, :string
  column :event_type, :string
  
  attr_accessor :subject
end

class TestFires1 < ActiveRecord::BaseWithoutTable
  column :state, :string
  column :other, :string
  
  acts_as_aasm_object :actor => :foo
  
  aasm_initial_state :first
  aasm_state_fires :first, :actor => :foo
  
  def foo
    "bar"
  end
  
  
end

class TestFires2< ActiveRecord::BaseWithoutTable
  column :state, :string
  column :state_changed_at, :datetime
  column :second_state_at, :datetime
  
  acts_as_aasm_object :actor => :foo
  
  aasm_initial_state :first
  aasm_state_fires :first, :actor => :foo, :callback => :cache_event
  aasm_state_fires :second, :actor => :foo
  
  aasm_event :mark_second do
    transitions :to => :second, :from => [:first]
  end
  
  def foo
    "bar"
  end
  
  def event
    @event
  end
  
  protected
  
  def cache_event(event)
    @event = event
  end
end

describe "Fires Event Creation" do
  it "should call to create a TestEvent" do
    test = TestFires1.new
    TestEvent.expects(:create!).with(:event_type => 'test_fires1_first', :subject => test, :actor => "bar")
    test.save.should be_true
  end
  
  it "should only be called once" do
    test = TestFires1.new
    TestEvent.expects(:create!).once
    test.save.should be_true
    test.other = "ok"
    test.save.should be_true
  end
  
  it "should skip creation when suppressed" do
    test = TestFires1.new
    TestEvent.expects(:create!).never
    test.suppress_state_events
    test.save.should be_true
  end
  
  it "should callback when requested" do
    test = TestFires2.new
    test.expects(:cache_event).once
    test.save.should be_true
  end
  
  it "should set state_changed_at when there" do
    Timecop.freeze do
      test = TestFires2.new
      test.state_changed_at.should be_nil
      test.second_state_at.should be_nil
      test.save.should be_true
      test.state_changed_at.should == Time.now
      test.second_state_at.should be_nil
    end
  end
  
  it "should set event timestamps when there" do
    Timecop.freeze do
      test = TestFires2.new
      test.mark_second
      test.state_changed_at.should be_nil
      test.second_state_at.should be_nil
      test.save.should be_true
      test.second_state_at.should == Time.now
      test.state_changed_at.should == Time.now
    end
  end
end
