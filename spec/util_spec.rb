require 'spec_helper'

class TestUtil1 < ActiveRecord::BaseWithoutTable
  def foo
    "bar"
  end
  
  def mult
    4*5
  end
end

describe StateEvent::Util do
  
  describe ".get_event_hash" do
    it "should call object to get values" do
      test = TestUtil1.new
      out = StateEvent::Util.get_event_hash(test, {:ok => :foo})
      out.should == {:subject => test, :ok => "bar"}
    end
    
    it "should raise event if method not known" do
      lambda { StateEvent::Util.get_event_hash(TestUtil1.new, {:ok => :bad}) }.should raise_error
    end
    
    it "should work for different types of properties" do
      test = TestUtil1.new
      out = StateEvent::Util.get_event_hash(test, {:ok => :foo, :thing => :self, :more => true, 
        :bad => false, :none => nil, :mult => Proc.new {|m| m.mult}, :val => "nice"})
      out.should == {:subject => test, :ok => "bar", :thing => test, 
        :more => true, :bad => false, :none => nil, :mult => 20, :val => "nice"}
    end
    
    it "should accept subject and event_type in hash" do
      test = TestUtil1.new
      other = TestUtil1.new
      out = StateEvent::Util.get_event_hash(test, {:ok => :foo, :subject => other, :event_type => "whatever"})
      out.should == {:subject => other, :event_type => "whatever", :ok => "bar"}
    end
  end
end