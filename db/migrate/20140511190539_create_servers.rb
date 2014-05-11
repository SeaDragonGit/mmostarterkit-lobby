class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :uuid
      t.string :addr
      t.integer :port
      t.integer :status
      t.text :intend

      t.timestamps
    end
  end
end
