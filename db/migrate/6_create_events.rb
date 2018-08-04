class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.date :date, :null => false
      t.time :start_time, :null => false
      t.time :end_time, :null => false
      t.time :duration, :null => false
      t.string :place, :null => false, :default => ""
      t.text :description, :null => false, :default => ""

      t.timestamps
    end
  end
end