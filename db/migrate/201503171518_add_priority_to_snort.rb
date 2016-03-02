class AddPriorityToSnort < ActiveRecord::Migration
  def change
    add_column :penetrations, :priority, :integer
  end
end
