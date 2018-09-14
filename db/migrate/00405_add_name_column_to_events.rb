class AddNameColumnToEvents < ActiveRecord::Migration[5.2]
    def change
      add_column :events, :name, :string, :null => false
    end
  end