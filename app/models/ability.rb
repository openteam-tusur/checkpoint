
class Ability
  include CanCan::Ability

  def initialize(user)
    return nil unless user

    can :manage, :all if user.administrator?

    can :read, Subdivision do |subdivision|
      user.manager_of?(subdivision)
    end

    can :manage, Docket do |docket|
      can? :read, docket.subdivision
    end
  end
end
