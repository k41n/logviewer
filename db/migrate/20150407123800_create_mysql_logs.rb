class CreateMysqlLogs < ActiveRecord::Migration
  def change
    create_table :mysql_logs do |t|
      t.string :action
      t.datetime :action_time
      t.integer :connection_id
      t.integer :state
      t.text :query
      t.string :user
      t.string :host
      t.string :ip
      t.string :db
      t.timestamps
    end
  end
end
