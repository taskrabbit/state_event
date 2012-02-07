require 'spec_helper'

class TestEvent1 < ActiveRecord::BaseWithoutTable
  acts_as_state_event
  
  column :value, :string
  column :number, :integer
  column :mult, :integer
  
  has_event_default :value do
    "something"
  end
  
  has_event_default :number, :calculate
  
  has_event_default :mult do |e|
    2*3
  end
  
  def calculate
    4*3
  end
end

describe "Event behaviors" do
  describe ".has_event_default" do
    it "should set the value before save" do
      test = TestEvent1.create(:number => 3, :mult => 2)
      test.value.should == "something"
    end
    it "should not set it if already set" do
      test = TestEvent1.create(:number => 3, :value => "else", :mult => 2)
      test.value.should == "else"
      test.number.should == 3
      test.mult.should == 2
    end
    it "should be able to call a method" do
      test = TestEvent1.create(:value => "ok", :mult => 2)
      test.number.should == 12
    end
    it "should be able to take property" do
      test = TestEvent1.create(:value => "ok", :number => 3)
      test.mult.should == 6
    end
  end
end