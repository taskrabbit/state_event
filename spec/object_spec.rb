require 'spec_helper'

class TestObject1 < ActiveRecord::BaseWithoutTable
  column :state, :string
  column :state_changed_at, :datetime
  column :second_state_at, :datetime
  
  acts_as_aasm_object :first, :actor => :foo
  
  aasm_state_fires :first, :actor => :foo
  aasm_state_fires :second, :actor => :foo
  
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
  
  acts_as_aasm_object :first, :actor => :foo
  aasm_state :first
  
  def foo
    "bar"
  end
end

describe "Object state interactions" do
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