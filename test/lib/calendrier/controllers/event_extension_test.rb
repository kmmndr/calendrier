require 'test_helper'

describe Calendrier::EventExtension do
  before do

    ActionController::Base.send(:include, Calendrier::EventExtension)
    @ctrl = ActionController::Base.new

    de = FakeDailyEvent.new(2012,5,21)
    de2 = FakeDailyEvent.new(2012,5,24)
    le = FakeLongEvent.new(Time.utc(2012,5,23).to_i, Time.utc(2012,5,25,12).to_i)

    @events_sorted_manually = {"2012"=>{
                                    "5"=>{
                                          "21"=>[ de ],
                                          "23"=>[ le ],
                                          "24"=>[ le, de2 ],
                                          "25"=>[ le ],
#                                         "26"=>[ le ] # this one should not be display
                                         }
                                       }
                               }


    @events_unordered = [ de, le, de2 ]

    @events = @events_sorted_manually

  end

  it "should integrate with ActionController::Base" do
    @ctrl.respond_to?(:sort_events).must_equal true
  end

  it "should return hash of events sorted by date" do
   @ctrl.sort_events(@events_unordered).must_equal @events_sorted_manually
  end

end

