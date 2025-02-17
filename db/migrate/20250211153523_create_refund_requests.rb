class CreateRefundRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :refund_requests do |t|
      t.text :description
      t.float :total
      t.date :paid_at
      t.string :status
      t.string :updated_by
      t.string :approved_by
      t.string :reproved_by
      t.datetime :requested_at
      t.datetime :approved_at
      t.datetime :reproved_at
      t.datetime :reimpursed_at

      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.references :supplier, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
