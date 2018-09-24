class Event < ApplicationRecord
    default_scope { order(start_time: :asc) }

    attr_accessor :repeated, :repeated_for

    belongs_to :group

    validates_presence_of :group, :name, :start_time, :end_time
    validate :start_time_is_not_before_today
    validate :end_time_is_after_start_time
    validate :end_time_is_same_day_as_start_time

    validates_length_of :name, minimum: 3, maximum: 250
    validates_length_of :place, maximum: 250, allow_blank: true
    validates_length_of :description, maximum: 1000, allow_blank: true

    after_create :create_repeated_events

    private def start_time_is_not_before_today
        return false if start_time.nil?

        if start_time < Time.now
            errors.add(:start_time, "cannot be before today") 
        end
    end

    private def end_time_is_after_start_time
        return false if start_time.nil? || end_time.nil?

        if end_time < start_time
            errors.add(:end_time, "cannot be before the start date")
        end
    end

    private def end_time_is_same_day_as_start_time
        return false if start_time.nil? || end_time.nil?

        if end_time > start_time.end_of_day
            errors.add(:end_time, "cannot be on a different day")
        end
    end

    # chiamato dopo la creazione di un evento
    # crea un numero di eventi uguale a repeated_for, a distanza di tempo uguale a repeated
    private def create_repeated_events
        if self.repeated.present? && self.repeated_for.present?
            self.transaction do
                tot_time = repeated
                n = 1
                while n < self.repeated_for do
                    Event.create(group_id: self.group_id,
                        name: self.name,
                        place: self.place,
                        description: self.description,
                        start_time: self.start_time + tot_time,
                        end_time: self.end_time + tot_time)
                    tot_time += repeated
                    n += 1
                end
            end
        end
    end


    # restituisce gli eventi compresi nel prossimo tempo dato come parametro,
    # di default restituisce gli eventi inclusi nella prossima settimana
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
