
class Ability
  include CanCan::Ability

  def initialize(user)
    return nil unless user

    can :manage, :all if user.administrator?

    can :show, Subdivision do |subdivision|
      user.manager_of?(subdivision)
    end

    can :show, Period do |period|
      user.manager?
      user.lecturer? && !period.exam_session?
    end

    can :show, Lecturer do |lecturer|
      user.permissions.map(&:context).include?(lecturer)
    end

    can :manage, Docket do |docket|
      can? :show, docket.subdivision && docket.period.editable?
    end

    can :read, Docket do |docket|
      can? :show, docket.subdivision
      docket.lecturer.permissions.map(&:user).include?(user)
    end

    can :edit, Docket do |docket|
       can? :read, docket && docket.period.editable?
    end

    can :change_lecturer, Docket do |doket|
      can? :show, docket.subdivision && docket.period.editable?
    end

    can :import, Docket do |docket|
      can? :show, docket.subdivision && docket.period.editable? && !docket.period.exam_session?
    end
  end
end
