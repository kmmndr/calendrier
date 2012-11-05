require 'test_helper'

describe Calendrier::CalendrierBuilder do
  before do

    ActionView::Base.send(:include, Calendrier::CalendrierHelper)
    ActionView::Base.send(:include, Calendrier::EventHelper)
    @view = ActionView::Base.new
    @cal_options = { :year => 2012, :month => 5, :day => 25, :start_on_monday => true, :title => 'This is the calendar title' }

    # preparing array for the month of may 2012
    @days_of_may = []
    @days_of_may << ''
    31.times do |idx|
      @days_of_may << (idx + 1).to_s
    end
    3.times { @days_of_may << '' }

    # preparing array for the week of the 25th of may 2012
    @days_of_may_weekly = []
    24.times do |hour_idx|
      @days_of_may_weekly << (hour_idx).to_s
      7.times do |day_idx|
        @days_of_may_weekly << ''
      end
    end

  end

  # builder

  it "should require context and elements" do
    proc { Calendrier::CalendrierBuilder::Builder.new }.must_raise ArgumentError
  end

  it "should raise NotImplementedError for Builder instance" do
    builder = Calendrier::CalendrierBuilder::Builder.new(@view)
    proc { builder.render }.must_raise NotImplementedError
  end

  # simple builder #

  it "should respond to render for SimpleBuilder instance" do
    builder = Calendrier::CalendrierBuilder::SimpleBuilder.new(@view)
    #proc { builder.render }.must_raise NotImplementedError
    builder.render(nil, nil)
  end

  it "should return valid code for monthly calendar" do
    options = { :display => :month }
    header, content = generate_header_and_content(options)
    builder = Calendrier::CalendrierBuilder::SimpleBuilder.new(@view, options)
    html_doc = Nokogiri::XML::Document.parse(builder.render(header, content).html_safe)
    html_doc.errors.must_equal []
  end

  it "should return valid code for weekly calendar" do
    options = { :display => :week }
    header, content = generate_header_and_content(options)
    builder = Calendrier::CalendrierBuilder::SimpleBuilder.new(@view, options)
    html_doc = Nokogiri::XML::Document.parse(builder.render(header, content).html_safe)
    html_doc.errors.must_equal []
  end

  it "should have the right calendar title" do
    cal = generate_calendar(:month)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_title = html_doc.css('div.calendar > span').map { |link| link.children.to_s }.first
    calendar_title.must_match /#{@cal_options[:title]}/
  end


  # monthly
  it "should return the default monthly calendar" do
    cal = generate_calendar(:month)
    cal.must_match %r{calendar month}
  end

  it "should have the right amount of lines for monthly calendar" do
    cal = generate_calendar(:month)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_lines = html_doc.css('div.calendar tr')
    calendar_lines_count = html_doc.css('div.calendar tr').count
    calendar_lines_count.must_equal 5
  end

  it "should have the right amount of columns for monthly calendar" do
    cal = generate_calendar(:month)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_columns_count = html_doc.css('div.calendar td').count
    calendar_columns_count.must_equal  5 * 7
  end

  it "should have the rights columns for monthly calendar" do
    cal = generate_calendar(:month)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_columns_arr = html_doc.css('div.calendar td')
    content_arr = calendar_columns_arr.map { |col| col.children.text.to_s }
    content_arr.must_equal @days_of_may
  end

  # weekly
  it "should return the weekly calendar" do
    cal = generate_calendar(:week)
    cal.must_match %r{calendar week}
  end

  it "should have the right amount of lines for weekly calendar" do
    cal = generate_calendar(:week)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_lines_count = html_doc.css('div.calendar tr').count
    calendar_lines_count.must_equal 24
  end

  it "should have the right amount of columns for monthly calendar" do
    cal = generate_calendar(:week)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_columns_count = html_doc.css('div.calendar td').count
    calendar_columns_count.must_equal  (1 + 7) * 24
  end

  it "should have the rights columns for monthly calendar" do
    cal = generate_calendar(:week)
    html_doc = Nokogiri::HTML(cal.html_safe)
    calendar_columns_arr = html_doc.css('div.calendar td')
    content_arr = calendar_columns_arr.map { |col| col.children.to_s }
    content_arr.must_equal @days_of_may_weekly
  end

  def generate_calendar(display = :month)
    options = @cal_options.merge :display => display
    header, content = generate_header_and_content(options)
    builder = Calendrier::CalendrierBuilder::SimpleBuilder.new(@view, options)
    builder.render(header, content).html_safe
  end

  def generate_header_and_content(options = {})
    display = options[:display] || :month
    header = []
    time_iterate(Time.utc(2012,5,21), Time.utc(2012,5,28)-1, 60*60*24) do |date|
      header << date.to_date
    end
    content = []
    content_intermediate = []
    if display == :month
      content_intermediate << content_hash(nil, nil)
      time_iterate(Time.utc(2012,5,1), Time.utc(2012,5,31), 60*60*24) do |time|
        content_intermediate << content_hash(time, nil)
      end
      3.times { content_intermediate << content_hash(nil, nil) }
    else
      24.times do |idx|
        time_iterate(Time.utc(2012,5,21), Time.utc(2012,5,27), 60*60*24) do |time|
          content_intermediate << content_hash(time + idx*60*60, nil)
        end
      end
    end

    (content_intermediate.count / 7).times do |idx|
      content << content_intermediate.slice(idx * 7, 7)
    end
    [header, content]
  end

  def content_hash(time, content)
    { time: time, content: content }
  end

  def time_iterate(start_time, end_time, step, &block)
    begin
      yield(start_time, start_time + step)
    end while (start_time += step) <= end_time
  end

end
