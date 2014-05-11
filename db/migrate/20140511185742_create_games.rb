class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :uuid
      t.string :server_uuid
      t.string :server_addr
      t.integer :server_port
      t.datetime :started_at
      t.datetime :over_at

      t.timestamps
    end
  end
end
