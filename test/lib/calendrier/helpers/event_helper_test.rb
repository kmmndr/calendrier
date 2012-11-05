require 'test_helper'

describe Calendrier::EventHelper do
  before do

    #ActionView::Base.send(:include, Calendrier::CalendrierHelper)
    ActionView::Base.send(:include, Calendrier::EventHelper)
    @view = ActionView::Base.new
    @cal_options = { :year => 2012, :month => 5, :day => 25, :start_on_monday => true }

    de = FakeDailyEvent.new(2012,5,21)
    de2 = FakeDailyEvent.new(2012,5,24)
    le = FakeLongEvent.new(Time.utc(2012,5,23).to_i, Time.utc(2012,5,25,12).to_i)

    @events_sorted_manually = {"2012"=>{
                                    "5"=>{
                                          "21"=>[ de ],
                                          "23"=>[ le ],
                                          "24"=>[ le, de2 ],
                                          "25"=>[ le ],
                                         }
                                       }
                               }

#                                          "26"=>[ le ] # this one should not be displayed

    @events = @events_sorted_manually

  end

  it "should integrate with ActionView::Base" do
    @view.respond_to?(:count_sorted_events).must_equal true
    @view.respond_to?(:yield_sorted_events).must_equal true
  end

  it "should count only one event" do
    cell_begin_time = Time.utc(2012, 5, 23, 12)
    cell_end_time = Time.utc(2012, 5, 23, 13)
    @view.count_sorted_events(@events, cell_begin_time, cell_end_time).must_equal 1
  end

  it "should count the two events" do
    cell_begin_time = Time.utc(2012, 5, 24, 12)
    cell_end_time = Time.utc(2012, 5, 24, 13)
    @view.count_sorted_events(@events, cell_begin_time, cell_end_time).must_equal 2
  end

  it "should count the right amount of events in the month" do
    calendar_begin_time = Time.utc(2012, 5, 1)
    calendar_end_time = Time.utc(2012, 5, 31)
    events_count_of_may = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0]

    step = 60 * 60 * 24 # 1.day

    events_counts = []

    time_iterate(calendar_begin_time, calendar_end_time, step) do |cell_begin_time, cell_end_time|
      events_counts << @view.count_sorted_events(@events, cell_begin_time, cell_end_time)
    end

    events_counts.must_equal events_count_of_may
  end

  it "should count the right amount of events in the week" do
    calendar_begin_time = Time.utc(2012, 5, 21, 0)
    calendar_end_time = Time.utc(2012, 5, 27, 23, 59, 59)
    events_count_of_one_week_in_may = []
    24.times { events_count_of_one_week_in_may << 1 }
    24.times { events_count_of_one_week_in_may << 0 }
    24.times { events_count_of_one_week_in_may << 1 }
    24.times { events_count_of_one_week_in_may << 2 }
    12.times { events_count_of_one_week_in_may << 1 }
    (12+24+24).times { events_count_of_one_week_in_may << 0 }

    step = 60 * 60 # 1.hour

    events_counts = []

    time_iterate(calendar_begin_time, calendar_end_time, step) do |cell_begin_time, cell_end_time|
      events_counts << @view.count_sorted_events(@events, cell_begin_time, cell_end_time)
    end

    events_counts.must_equal events_count_of_one_week_in_may
  end


  def time_iterate(start_time, end_time, step, &block)
    begin
      yield(start_time, start_time + step)
    end while (start_time += step) <= end_time
  end

end

