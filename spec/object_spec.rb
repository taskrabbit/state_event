require 'spec_helper'

class TestEvent2 < ActiveRecord::BaseWithoutTable
  acts_as_state_event
  column :something, :string
  column :event_type, :string
  column :else, :integer
  column :created_at, :datetime
  
  attr_accessor :subject
end

class TestObject1 < ActiveRecord::BaseWithoutTable
  column :state, :string
  column :state_changed_at, :datetime
  column :second_state_at, :datetime
  
  acts_as_aasm_object :first, :something => :foo
  
  aasm_state_fires :first, :something => :foo
  aasm_state_fires :second, :something => :foo
  
  def foo
    "bar"
  end
  
  aasm_event :mark_second do
    transitions :to => :second, :from => [:first]
  end

end

class TestObject2 < ActiveRecord::BaseWithoutTable
  column :state, :string
  column :first_state_at, :datetime
  
  acts_as_aasm_object :first, :something => :foo, :else => 42, :time => :stamp
  aasm_state :first
  
  def foo
    "bar"
  end
  
  def stamp
    @stamp ||= Time.now
  end
end

describe "Object state interactions" do
  before(:each) do
    @saved_config = ::StateEvent::Config.event_class
    ::StateEvent::Config.event_class = TestEvent2
  end
  after(:each) do
    ::StateEvent::Config.event_class = @saved_config
  end
  
  describe "#default_aasm_event" do
    it "should return a default object" do
      test = TestObject2.new
      event = test.default_aasm_event
      event.event_type.should == "test_object2"
      event.something.should == "bar"
      event.else.should == 42
      event.subject.should == test
    end
  
    it "should allow adding of times" do
      test = TestObject2.new
      event = test.default_aasm_event(:time => true)
      event.event_type.should == "test_object2"
      event.something.should == "bar"
      event.else.should == 42
      event.subject.should == test
      event.created_at.should == test.stamp
    end
  end
  
  describe "#create_aasm_event" do
    it "should return a default object" do
      test = TestObject2.new
      event = test.create_aasm_event("xyz")
      event.event_type.should == "test_object2_xyz"
      event.something.should == "bar"
      event.else.should == 42
      event.subject.should == test
    end
  
    it "should allow adding of times" do
      test = TestObject2.new
      event = test.create_aasm_event("abc", :something => nil, :else => 32)
      event.event_type.should == "test_object2_abc"
      event.something.should be_nil
      event.else.should == 32
      event.subject.should == test
    end
    
    it "should allow changing of event_type" do
      test = TestObject2.new
      event = test.create_aasm_event(nil, :something => nil, :else => 32, :event_type => "something_else")
      event.event_type.should == "something_else"
      event.something.should be_nil
      event.else.should == 32
      event.subject.should == test
    end
  end
  
  describe "time recoriding" do
    it "should set the initial state" do
      test = TestObject1.new
      test.state.should be_nil
      test.should be_first
      test.should_not be_second
    end
  
    it "should set state_changed_at when there" do
      Timecop.freeze do
        test = TestObject1.new
        test.state_changed_at.should be_nil
        test.second_state_at.should be_nil
        test.save.should be_true
        test.state_changed_at.should == Time.now
        test.second_state_at.should be_nil
      end
    end
  
    it "should set named event timestamps when there" do
      Timecop.freeze do
        test = TestObject1.new
        test.mark_second
        test.state_changed_at.should be_nil
        test.second_state_at.should be_nil
        test.save.should be_true
        test.second_state_at.should == Time.now
        test.state_changed_at.should == Time.now
      end
    end
  
    it "should set the time on the first state" do
      Timecop.freeze do
        test = TestObject2.new
        test.first_state_at.should be_nil
        test.save.should be_true
        test.first_state_at.should == Time.now
      end
    end
  end
end