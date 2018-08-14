class Event < ApplicationRecord

    belongs_to :group

    validates_presence_of :group, :start_time, :end_time
    validate :start_time_is_not_before_today
    validate :end_time_is_after_start_time

    def start_time_is_not_before_today
        return false if start_time.nil?

        if start_time < Time.now
            errors.add(:start_time, "cannot be before today") 
        end
    end

    def end_time_is_after_start_time
        return false if start_time.nil? || end_time.nil?

        if end_time < start_time
            errors.add(:end_time, "cannot be before the start date") 
        end
    end


    def self.next(time = 1.week)
        where(start_time: Time.now.beginning_of_day..(Time.now+time))
        .where("end_time > ?", Time.now)
    end

    # restituisce la durata dell'evento nel formato HH:MM:SS
    def duration
        seconds_diff = (self.start_time - self.end_time).to_i.abs

        hours = seconds_diff / 3600
        seconds_diff -= hours * 3600

        minutes = seconds_diff / 60
        seconds_diff -= minutes * 60

        seconds = seconds_diff

        return "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end
    
end
