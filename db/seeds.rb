user = User.find_or_create_by_uid('1')
user.permissions.create :role => :administrator, :email => 'mail@openteam.ru'
