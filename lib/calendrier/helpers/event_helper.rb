module Calendrier
  module EventHelper

    def count_sorted_events(events_by_date, cell_begin_time, cell_end_time)
      counter = 0
      sorted_events_do(events_by_date, cell_begin_time, cell_end_time) { |event| counter += 1 }
      counter
    end

    def yield_sorted_events(events_by_date, cell_begin_time, cell_end_time, &block)
      sorted_events_do(events_by_date, cell_begin_time, cell_end_time) { |event| yield event }
    end

    def get_cell_sorted_events(events_by_date, cell_begin_time, cell_end_time)
      events = []
      sorted_events_do(events_by_date, cell_begin_time, cell_end_time) { |event| events << event }
      events
    end

    protected

    def sorted_events_do(events_by_date, cell_begin_time, cell_end_time, &block)
      begin
        unless events_by_date[cell_begin_time.year.to_s][cell_begin_time.month.to_s][cell_begin_time.day.to_s].nil?
          events_by_date[cell_begin_time.year.to_s][cell_begin_time.month.to_s][cell_begin_time.day.to_s].each_with_index do |event, idx|
            yield event, idx if display_event?(event, cell_begin_time, cell_end_time) && block_given?
          end
        end
      rescue NoMethodError
      end
    end

    def display_event?(event, cell_begin_time, cell_end_time)
      event_begin_time = nil
      event_end_time = nil

      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        event_begin_time = Time.local(event.year, event.month, event.day, event.hour, event.min, event.sec)
        event_end_time = Time.local(event.year, event.month, event.day, event.hour, 59, 59)
      end

      if event.respond_to?(:begin_time) && event.respond_to?(:end_time)
        event_begin_time = event.begin_time.localtime
        event_end_time = event.end_time.localtime
      end

      if event_begin_time.to_i <= cell_begin_time.to_i
        if event_end_time.to_i <= cell_end_time.to_i
          if event_end_time.to_i > cell_begin_time.to_i
            ok = true
          end
        else
          ok = true
        end
      else
        if event_end_time.to_i <= cell_end_time.to_i
          ok = true
        else
          if event_begin_time.to_i < cell_end_time.to_i
            ok = true
          end
        end
      end

      return ok
    end

  end
end
