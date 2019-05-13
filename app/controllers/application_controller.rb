class ApplicationController < ActionController::Base
  before_action :cheat_login_check, {only: [
    :account,
    :account_info,
    :account_info_service,
    :feed,
    :upload,
    :edit,
    :delete
  ]}

  def cheat_login_check()
    if !(session[:user_id])
      flash[:message] = "You need login!!"
      redirect_to("/login")
    end
  end
end