class Attachment < ApplicationRecord
    validates_presence_of :name, :data

    def name=(new_name)
        write_attribute("name", sanitize_filename(new_name))
    end

    private def sanitize_filename(filename)
        if filename != nil
            just_filename = File.basename(filename)
            just_filename.gsub(/[^\w\.\-]/, '_')
        end
    end
end