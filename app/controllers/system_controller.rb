class SystemController < ApplicationController
  before_action :authenticate_admin_request, only: [:index, :setting]

  def index
  end

  def setting
    setting = User.system.settings.find_by(key: setting_params["key"])
    setting.update(setting_params)
    User.system.reload
    render :index
  end

protected

  def setting_params
    params.require(:setting).permit(
      :key,
      :value
    )
  end

end
