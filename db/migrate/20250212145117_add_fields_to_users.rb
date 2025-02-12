class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :string
    add_column :users, :active, :boolean
    add_column :users, :created_by, :string
    add_column :users, :updated_by, :string
  end
end
