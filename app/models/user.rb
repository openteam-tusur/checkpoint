class User
  include AuthClient::User

  def self.with_permissions(role)
    Permission.where.not(:user_id => nil).where(:role => role).uniq
  end

  def app_name
    'checkpoint'
  end

  def subdivisions
    Subdivision.joins(:permissions).where('permissions.user_id' => id).uniq
  end

  def lecturers
    Lecturer.joins(:permissions).where('permissions.user_id' => id).uniq
  end

  def after_signed_in
    Permission.where("user_id = '' or user_id is null").where(:email => self.email).update_all(:user_id => self.id)

    super
  end
end
