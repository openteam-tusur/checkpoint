class PeriodsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :all
  custom_actions :resource => :import

  def import
    import!{
      flash[:notice] = 'Генерация ведомостей запущена в фоновом режиме'
      Import.new(@period, params['import']['group_pattern']).delay.import
      redirect_to @period and return
    }
  end
end
