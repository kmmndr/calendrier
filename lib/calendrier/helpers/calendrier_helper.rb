module Calendrier
  module CalendrierHelper
    DAYS_IN_WEEK = 7
    HOURS_IN_DAY = 24

    DIMANCHE = 0
    LUNDI = 1

    def calendrier(options = {}, &block)
      year = options[:year] || Time.now.year
      month = options[:month] || Time.now.month
      day = options[:day] || Time.now.day
      display = options[:display] || :month

      builder_options = options
      builder_options[:display] = display unless builder_options.include? :display

      builder = (options.delete(:builder) || CalendrierBuilder::SimpleBuilder).new(self, options)
      start_on_monday = options[:start_on_monday].nil? ? true : options[:start_on_monday]

      first_day_of_month = Time.utc(year, month, 1).wday
      first_day_of_month = shift_week_days(first_day_of_month, 1) if start_on_monday

      days_in_month = Time.utc(year, month, 1).end_of_month.day
      days = (days_in_month + first_day_of_month)
      weeks_in_month = (days / DAYS_IN_WEEK) + (days % DAYS_IN_WEEK != 0 ? 1 : 0)

      days_arr = []
      selected_calendar_date = Date.new(year, month, day)

      day_shift = (start_on_monday ? LUNDI : DIMANCHE)
      first_day_of_week = selected_calendar_date - (selected_calendar_date.wday - day_shift)


      if display == :week
        table_head = (0...DAYS_IN_WEEK).map { |index| first_day_of_week + index }
        table_content = []
        (0...HOURS_IN_DAY).each do |hour_index|
          table_content_row = []
          DAYS_IN_WEEK.times do |index|
            this_day = (first_day_of_week + index)
            cell_begin_time = Time.utc(this_day.year, this_day.month, this_day.day, hour_index)
            cell_content = nil
            cell_end_time = cell_begin_time + 3600
            cell_content = capture(cell_begin_time, cell_end_time, &block) if block_given?
            table_content_row << { time: cell_begin_time, content: cell_content}
          end
          table_content << table_content_row
        end
      else # :month
        table_head = (0...DAYS_IN_WEEK).map { |index| first_day_of_week + index }
        day_counter = 0
        weeks_in_month.times do |week_index|
          (0...DAYS_IN_WEEK).each do |day_index|
            day_counter += 1 if (day_index == first_day_of_month || day_counter != 0) 
            days_arr << nil if (day_counter == 0 && day_index != first_day_of_month) || (day_counter != 0 && day_counter > days_in_month) 
            days_arr << day_counter if (day_counter == 0 && day_index == first_day_of_month) || (day_counter != 0 && day_counter <= days_in_month) 
          end
        end

        table_content = []
        while days_arr.length > 0
          table_content_row = []
          one_week = days_arr.slice!(0, DAYS_IN_WEEK)
          one_week.each do |one_day|
            cell_content = nil
            cell_begin_time = nil

            if one_day.is_a?(Integer)
              cell_begin_time = Time.utc(year, month, one_day)
              cell_end_time = cell_begin_time + 3600*24
              cell_content = capture(cell_begin_time, cell_end_time, &block) if block_given?
            end

            table_content_row << { time: cell_begin_time, content: cell_content}
          end
          table_content << table_content_row
        end
      end

      builder.render(table_head, table_content).html_safe
    end

    protected

    def shift_week_days(wday, index)
      wday -= index
      wday += DAYS_IN_WEEK if wday < 0

      return wday
    end

  end
end
