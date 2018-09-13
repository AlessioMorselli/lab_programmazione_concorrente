# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'json'

# Inserimento nel database dei corsi

file_path = File.dirname(__FILE__) + '/degrees.json'
file = File.read(file_path)
degree_list = JSON.parse(file)
puts "Loaded: "+file_path

degree_list.each do |degree|
    d = Degree.create!(name: degree["name"], years: degree["num_years"])
    
    degree["years"].each do |year|
        year["courses"].each do |course|
            c = Course.find_or_create_by!(name: course["name"])
            g = Group.create!(name: "#{course["name"]}", course_id: c.id, private: true, description: "Gruppo ufficiale di #{course["name"]} del corso di studio #{degree["name"]} (Anno #{year["year"]})")
            DegreeCourse.create!(degree_id: d.id, course_id: c.id, year: year["year"], group_id: g.id)
        end
    end

    puts "Inserted degree: #{degree["name"]}"
end