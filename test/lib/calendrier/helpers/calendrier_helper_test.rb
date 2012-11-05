require 'test_helper'

describe Calendrier::CalendrierHelper do
  before do

    ActionView::Base.send(:include, Calendrier::CalendrierHelper)
    ActionView::Base.send(:include, Calendrier::EventHelper)
    @view = ActionView::Base.new
    @cal_options = { :year => 2012, :month => 5, :day => 25, :start_on_monday => true }
    de = FakeDailyEvent.new(2012,5,21)
    de2 = FakeDailyEvent.new(2012,5,24)
    le2 = FakeLongEvent.new(Time.utc(2012,5,23).to_i, Time.utc(2012,5,25).to_i)
    @events_test = {"2012"=>{
                                "5"=>{
                                      "21"=>[ de ],
                                      "23"=>[ le2 ],
                                      "24"=>[ de2, le2 ],
                                      "25"=>[ le2 ],
                                      "26"=>[ le2 ] # this one should not be display
                                     }
                               }
                      }

    # preparing events counter array for the week of the 25th of may 2012
    @counter_of_may_weekly = []
    24.times { @counter_of_may_weekly = @counter_of_may_weekly + [1,0,1,2,0,0,0] }

    # preparing events counter array for the week of the 25th of may 2012
    @counter_of_may_monthly = []
    20.times { @counter_of_may_monthly << 0 }
    @counter_of_may_monthly << 1
    @counter_of_may_monthly << 0
    @counter_of_may_monthly << 1
    @counter_of_may_monthly << 2
    7.times { @counter_of_may_monthly << 0 }
  end

  it "should integrate with ActionView::Base" do
    @view.respond_to?(:calendrier).must_equal true
  end

  it "should have the right amount of events for monthly calendar" do
    counts = []
    cal = @view.calendrier(@cal_options.merge :display => :month) do |cell_begin_time, cell_end_time|
      counts << @view.count_sorted_events(@events_test, cell_begin_time, cell_end_time)
    end
    counts.must_equal @counter_of_may_monthly
  end

  it "should have the right amount of events for weekly calendar" do
    counts = []
    cal = @view.calendrier(@cal_options.merge :display => :week) do |cell_begin_time, cell_end_time|
      counts << @view.count_sorted_events(@events_test, cell_begin_time, cell_end_time)
    end
    counts.must_equal @counter_of_may_weekly
  end


end

