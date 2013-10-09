
class Ability
  include CanCan::Ability

  def initialize(user)
    return nil unless user

    can :manage, Permission if user.administrator?
    can :index, User if user.administrator?
  end
end
