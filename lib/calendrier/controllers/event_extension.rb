module Calendrier
  module EventExtension

    def sort_events(events)
      events_by_date = {}

      events.sort_by { |obj| get_event_stamp(obj) }.each do |event|
        begin_date = Time.at(get_event_stamp(event)).to_date
        end_date = Time.at(get_event_stamp(event, :end_time => true)).to_date

        duration_in_days = (end_date - begin_date).to_i + 1

        duration_in_days.times do |index|
          current_date = begin_date + index
          date_arr = [current_date.year.to_s, current_date.month.to_s, current_date.day.to_s]
          exist = begin
            true if events_by_date[current_date.year.to_s][current_date.month.to_s][current_date.day.to_s]
          rescue NoMethodError
            false
          end
          # create recursive hash {"2012"=>{"5"=>{"21"=>[]}}}
          events_by_date = events_rmerge(events_by_date, date_arr.reverse.inject([]) { |a, n| {n=>a} }) unless exist

          unless events_by_date[current_date.year.to_s][current_date.month.to_s][current_date.day.to_s].include? event
            events_by_date[current_date.year.to_s][current_date.month.to_s][current_date.day.to_s] << event
          end
        end
      end

      return events_by_date
    end

    protected

    def events_rmerge(hash, other_hash)
      r = {}
      hash.merge(other_hash) do |key, oldval, newval|
        r[key] = oldval.class == hash.class ? events_rmerge(oldval, newval) : newval
      end
    end

    def get_event_stamp(event, options = {})
      end_time = options[:end_time]
      ret = nil

      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        ret = Time.local(event.year, event.month, event.day)
      elsif event.respond_to?(:begin_time) && event.respond_to?(:end_time)
        ret = end_time ? event.end_time.localtime : event.begin_time.localtime
      end

      return ret
    end

  end
end
