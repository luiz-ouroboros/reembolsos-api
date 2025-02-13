class CreateActionLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :action_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.references :recordable, polymorphic: true, null: false
      t.jsonb :details, default: {}
      t.timestamps
    end
  end
end
