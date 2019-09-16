class ApplicationController < ActionController::Base
  before_action :set_cache_buster

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

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def cheat_login_check()
    if !(session[:user_id])
      flash[:message] = "You need login!!"
      redirect_to login_path
    end
  end
end
