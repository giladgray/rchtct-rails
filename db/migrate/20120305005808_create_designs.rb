class CreateDesigns < ActiveRecord::Migration
  def self.up
    create_table :designs do |t|
      t.string :name
      t.text :content
      t.integer :width
      t.integer :height
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :designs
  end
end
