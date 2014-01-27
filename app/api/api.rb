class API < Grape::API
  prefix :api
  format :json

  get :permissions do
    user = User.find_by_uid(params[:uid])
    return { :error => 'User not found' } unless user.present?

    { :permissions => user.permissions.map do |permission|
      { :role => permission.role,
        :context => {
          :kind => permission.context_type,
          :remote_id => permission.context_id,
          :title => permission.context.try(:to_s)
        }
      }
    end
    }
  end
end
