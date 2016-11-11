class CheckpointAPI < Grape::API
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

  get :lecturer_permissions do
    lecturer = Lecturer.find_by( surname: params[:surname],
                                name: params[:name],
                                patronymic: params[:patronymic] )
    result = []
    if lecturer
      lecturer.permissions.each do |p|
        result << { user_id: p.user_id, email: p.email }
      end
    end
    result
  end
end
