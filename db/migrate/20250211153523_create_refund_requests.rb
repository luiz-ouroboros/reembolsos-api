class CreateRefundRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :refund_requests do |t|
      t.text :description
      t.float :total
      t.date :paid_at
      t.string :status
      t.references :supplier, null: true, foreign_key: true
      t.string :requested_by
      t.string :approved_by
      t.datetime :requested_at
      t.datetime :approved_at
      t.datetime :reimpursed_at

      t.timestamps
    end
  end
end
