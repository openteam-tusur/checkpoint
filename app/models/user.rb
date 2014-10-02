class User
  include AuthClient::User

  def app_name
    'checkpoint'
  end
end
