class AddIndexToDegreesName < ActiveRecord::Migration[5.2]
  def change
    add_index :degrees, :name, unique: true
  end
end