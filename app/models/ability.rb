# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :manage, Tag
    can :manage, Supplier
    can :manage, RefundRequest

    if user.admin?
      can :manage, User
    end
  end
end
