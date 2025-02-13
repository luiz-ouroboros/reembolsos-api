class ActionLog < ApplicationRecord
  belongs_to :user
  belongs_to :recordable, polymorphic: true

  def self.log(user, action, record, details = {})
    create!(user: user, action: I18n.t("log.#{action}", **details), recordable: record, details: details)
  end
end
