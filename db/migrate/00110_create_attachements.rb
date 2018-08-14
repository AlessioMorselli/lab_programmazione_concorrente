class CreateAttachements < ActiveRecord::Migration[5.2]
    def change
      create_table :attachements do |t|
        t.string :name, :null => false
        t.string :mime_type, :null => false
        t.binary :data, :null => false
  
        t.timestamps
      end
    end
end