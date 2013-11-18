class PeriodsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :all
  custom_actions :resource => :import
  def import
    import!{
      flash[:notice] = 'Генерация ведомостей запущена в фоновом режиме'
      redirect_to @period and return
    }
  end
end
