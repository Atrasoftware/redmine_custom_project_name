class AddIndexesToProject < ActiveRecord::Migration
  def change
    add_index :projects, :identifier_with_cfs
  end
end