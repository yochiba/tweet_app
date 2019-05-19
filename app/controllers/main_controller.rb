class MainController < ApplicationController

  def top
    # login後に、直接topへのURLにアクセスした場合: session有効accountにredirect
    if session[:user_id]
      redirect_to("/account/#{session[:user_id]}")
    end
  end

  def login
    
  end

  def login_service
    user_info = User.find_by(user_id: params[:user_id])
    if user_info == nil
      flash[:message] = "This user doesn't exist!! try again!"
      render("/main/login")
    elsif user_info != nil && user_info.authenticate(params[:password])
      logger.info(user_info.user_id)
      session[:user_id] = params[:user_id]
      redirect_to("/account/#{session[:user_id]}") 
    else
      logger.info("[info]: passwordが違いました。")
      flash[:message] = "Password is wrong!! try again!"
      render("/main/login")
    end
  end

  def logout_service
    # sessionの削除
    reset_session
    flash[:message] = "Logout"
    logger.info("[info]: logoutに成功しました。")
    redirect_to("/login")
  end

  def registration
  end

  def registration_service
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @email = params[:email]
    @user_id = params[:user_id]

    user_info = User.new(
      first_name: @first_name,
      last_name: @last_name,
      email: @email,
      user_id: @user_id,
      password: params[:password],
      icon_image: "default.jpg"
    )

    user_info.save!
    if user_info.save!
      session[:user_id] = params[:user_id]
      redirect_to("/account/#{session[:user_id]}")
    else
      # FIXME error messageの表示方法
      flash[:message] = "#{user_info.errors.full_messages}"
      render("/main/registration")
    end
  end

  def account
  end

  def account_info
    @account_info = User.find_by(user_id: params[:user_id])
  end

  def account_info_service
    user_info = User.find_by(user_id: params[:user_id])

    if params[:edited_icon_image]
      # FIXME account edit imageが適用されない問題 -> cache処理を追加
      image_info = params[:edited_icon_image]
      File.binwrite("public/icon_images/#{user_info.id}.jpg", image_info.read)
      user_info.icon_image = "#{user_info.id}..jpg"
      logger.info("[info]: icon_imageが変更されました。")
    end

    if user_info.user_id != params[:edited_user_id]
      edited_user_id = params[:edited_user_id]
      if edited_user_id.empty? || edited_user_id.nil? || edited_user_id.blank?
        logger.info("[info]: user_idは変更されませんでした。")
      else
        user_info.user_id = params[:edited_user_id]
        logger.info("[info]: user_idが変更されました。")
      end
    end

    if user_info.email != params[:edited_email]
      edited_email = params[:edited_email]
      if edited_email.empty? || edited_email.nil? || edited_email.blank?
        logger.info("[info]: emailは変更されませんでした。")
      else
        user_info.email = params[:edited_email]
        logger.info("[info]: emailが変更されました。")
      end
    end

    if !(user_info.authenticate(params[:edited_password]))
      edited_password = params[:edited_password]
      # passwordに何も変更がない場合、空の文字が送られてしまうので、それを防ぐためのための処理
      if edited_password.empty? || edited_password.nil? || edited_password.blank?
        logger.info("[info]: passwordは変更されませんでした。")
      else
        user_info.password = params[:edited_password]
        logger.info("[info]: passwordが変更されました。")
      end
    end
    
    user_info.save!
    if user_info.save!
      # user_id変更後にsessionを更新    
      session[:user_id] = user_info.user_id
      logger.info("[info]: redirectに成功しました。")
      redirect_to("/account/#{session[:user_id]}")
    else
      logger.info(user_info.errors.full_messages)
      render("/main/account_info")
    end
  end

  def all_users
    @accounts_list = User.all.where.not(user_id: session[:user_id])
  end

  def another_user
    @another_user = User.find_by(user_id: params[:another_user_id])
  end

  def another_user_service

  end
end
