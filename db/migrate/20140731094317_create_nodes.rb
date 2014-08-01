class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :username
      t.string :itemname

      t.timestamps
    end
  end
end
