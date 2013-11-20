
class Ability
  include CanCan::Ability

  def initialize(user)
    return nil unless user

    can :manage, :all if user.administrator?

    if user.manager?
      can :read, Subdivision do |subdivision|
        user.manager_of?(subdivision)
      end

      can :read, Period

      can :read, Lecturer

      can :read, Docket do |docket|
        can?(:read, docket.subdivision)
      end

      can [:edit, :update], Docket do |docket|
        can?(:read, docket.subdivision) && docket.period.editable?
      end

      can :change_lecturer, Docket do |docket|
        can?(:edit, docket)
      end

      can :import, Docket do |docket|
        can?(:edit, docket) && !docket.period.exam_session?
      end
    end

    if user.lecturer?
      can :read, Lecturer do |lecturer|
        user.permissions.map(&:context).include?(lecturer)
      end

      can :read, Period do |period|
        user.lecturer? && !period.exam_session?
      end

      can :read, Docket do |docket|
        can?(:read, docket.lecturer)
      end

      can [:edit, :update], Docket do |docket|
        can?(:read, docket) && docket.period.editable?
      end
    end
  end
end
