class ApplicationController < ActionController::Base
  before_action :cheat_login_check, {only: [
    :account,
    :account_info,
    :account_info_service,
    :feed,
    :upload,
    :edit,
    :delete,
    :all_users,
    :another_user,
    :another_user_service,
    :delete_account,
    :delete_account_service,
    :logout_service,
    :all_users,
    :other_user,
    :other_user_service,
    :request_list,
    :request_service,
    :friend_list
  ]}

  def cheat_login_check()
    if !(session[:user_id])
      flash[:message] = "You need login!!"
      redirect_to("/login")
    end
  end
end
