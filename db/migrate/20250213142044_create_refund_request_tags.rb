class CreateRefundRequestTags < ActiveRecord::Migration[8.0]
  def change
    create_table :refund_request_tags do |t|
      t.references :refund_request, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
