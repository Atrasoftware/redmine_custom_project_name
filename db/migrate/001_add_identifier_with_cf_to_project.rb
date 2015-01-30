class AddIdentifierWithCfToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :identifier_with_cfs, :string

  end
  def self.down
    remove_column :projects, :identifier_with_cfs
  end
end