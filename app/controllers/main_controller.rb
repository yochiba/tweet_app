class MainController < ApplicationController
  def top
    # login後に、直接topへのURLにアクセスした場合: session有効accountにredirect
    if session[:user_id]
      redirect_to account_path(session[:user_id])
    end
  end

  def login   
  end

  def login_service
    @user_info = User.find_by(user_id: params[:user_id])
    if @user_info == nil
      flash.now[:message] = "This user doesn't exist!! try again!"
      render("/main/login")
    elsif @user_info != nil && @user_info.authenticate(params[:password])
      logger.info(@user_info.user_id)
      session[:user_id] = params[:user_id]
      redirect_to account_path(session[:user_id])
    else
      logger.info("[info]: passwordが違いました。")
      flash.now[:message] = "Password is wrong!! try again!"
      render("/main/login")
    end
  end

  def logout_service
    # sessionの削除
    session.delete(:user_id)
    flash.now[:message] = "Logout"
    logger.info("[info]: logoutに成功しました。")
    redirect_to login_path
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
    if user_info.valid?
      user_info.save!
      session[:user_id] = params[:user_id]
      redirect_to account_path(session[:user_id])
    else
      flash.now[:message] = "blank!!"
      render("/main/registration")
    end
  end

  # アカウント処理関連
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
      user_info.update(icon_image: "#{user_info.id}.jpg")
      logger.info("[info]: icon_imageが変更されました。")
    end

    if user_info.user_id != params[:edited_user_id]
      edited_user_id = params[:edited_user_id]
      if edited_user_id.present?
        user_info.update(user_id: params[:edited_user_id])
        logger.info("[info]: user_idが変更されました。")
      else
        logger.info("[info]: user_idは変更されませんでした。")
      end
    end

    if user_info.email != params[:edited_email]
      edited_email = params[:edited_email]
      if edited_email.present?
        user_info.update(email: params[:edited_email])
        logger.info("[info]: emailが変更されました。")
      else
        logger.info("[info]: emailは変更されませんでした。")
      end
    end

    if !(user_info.authenticate(params[:edited_password]))
      edited_password = params[:edited_password]
      # passwordに何も変更がない場合、空の文字が送られてしまうので、それを防ぐためのための処理
      if edited_password.present?
        user_info.update(password: params[:edited_password])
        logger.info("[info]: passwordが変更されました。")
      else
        logger.info("[info]: passwordは変更されませんでした。")
      end
    end
    
    if user_info.valid?
      # user_id変更後にsessionを更新
      session[:user_id] = user_info.user_id
      logger.info("[info]: redirectに成功しました。")
      redirect_to account_path(session[:user_id])
    else
      flash[:message] = "Editting account info is denied"
      logger.info(user_info.errors.full_messages)
      render("/main/account_info")
    end
  end

  # アカウント削除ページ
  def delete_account
  end

  # アカウント削除処理
  def delete_account_service
    delete_user_info = User.find_by(user_id: session[:user_id])

    if delete_user_info.authenticate(params[:password])
      delete_friend_info_user = Friend.where(user_id: session[:user_id])
      delete_friend_info_other = Friend.where(friend_id: session[:user_id])
      delete_request_info_user = Request.where(user_id: session[:user_id])
      delete_request_info_other = Request.where(friend_id: session[:user_id])
      delete_post = Post.where(user_id: session[:user_id])
      # Reaction 自分以外のユーザのreaction情報削除
      # TODO 以下の処理改善
      delete_post.each do |post|
        delete_reaction_other = Reaction.where(post_id: post.id)
        delete_reaction_other.destroy_all
      end
      # Reaction 自分のreaction情報削除
      delete_reaction_user = Reaction.where(user_id: session[:user_id])
    
      if delete_user_info.destroy && delete_friend_info_user.destroy_all && delete_friend_info_other.destroy_all && delete_request_info_user.destroy_all && delete_request_info_other.destroy_all && delete_post.destroy_all && delete_reaction_user.destroy_all
        session.delete(:user_id)
        flash.now[:message] = "Account was deleted"
        redirect_to home_path
      end
    end
    flash.now[:message] = "Password is wrong"
    render("/main/delete_account")
  end

  # 友達機能関連
  def all_users
    @accounts_list = User.all.where.not(user_id: session[:user_id])

    friend_request = Request.find_by(
      user_id: session[:user_id],
      friend_id: params[:other_user_id]
    )
    # pending_flg = 0
    if friend_request == nil
      logger.info("[info]: nilです！")
    elsif friend_request.pending_flg == 1
      # pending_flg = 1
      logger.info("[info]: pending_flg = #{friend_request.pending_flg}")
    end
  end

  def other_user
    @relationship_flg = 0
    @other_user = User.find_by(user_id: params[:other_user_id])
    friend_user = Friend.find_by(
      user_id: session[:user_id],
      friend_id: params[:other_user_id]
    )
    friend_other = Friend.find_by(
      user_id: params[:other_user_id],
      friend_id: session[:user_id]
    )
    # リクエストを送受信を判別する処理
    friend_request = Request.find_by(
      user_id: session[:user_id], #aa
      friend_id: params[:other_user_id], #bb
    )
    # relationship_flg
    # 0: 初期値(Friend Request)
    # 1: すでに友達(Friend, Delete)
    # 2: 自分がリクエストを送信中(pending)
    # 3: 相手からリクエストあり(Accept, Reject)
    if friend_user != nil && friend_other != nil
      @relationship_flg = 1
      logger.info("[info]: #{session[:user_id]}と#{params[:other_user_id]}は友達です。") 
    end

    if friend_request == nil
      logger.info("[info]: 自分からの友達リクエストはありません。nilです。")
    elsif friend_request != nil && friend_request.pending_flg == 1
      @relationship_flg = 2
      logger.info("[info]: #{friend_request.friend_id}にリクエストを送信中です。")      
    end

    if friend_request == nil
     logger.info("[info]: 相手からの友達リクエストはありません。nilです。")
    elsif friend_request != nil && friend_request.pending_flg == 2
      @relationship_flg = 3
      logger.info("[info]: #{friend_request.user_id}から友達リクエストがあります。")
    end
  end

  # 友達リクエスト処理
  # pending_flg
  # 1: user_idを基準にリクエストを送った側
  # 2: user_idを基準にリクエストを受け取った側
  def other_user_service
    if params[:pending_flg] == "request"
      friend_request_user = Request.new(
        user_id: session[:user_id],
        friend_id: params[:other_user_id],
        pending_flg: 1
      )

      friend_request_other = Request.new(
        user_id: params[:other_user_id],
        friend_id: session[:user_id],
        pending_flg: 2
      )

      if friend_request_user.valid? && friend_request_other.valid?
        friend_request_user.save!
        friend_request_other.save!
        redirect_to other_user_path(session[:user_id], params[:other_user_id])
      else
        flash.now[:message] = "Friend Request Failed!"
        render("/main/all_users")
      end
    elsif params[:pending_flg] == "cancel"
      request_cancel_user = Request.find_by(
        user_id: session[:user_id],
        friend_id: params[:other_user_id]
      )
      request_cancel_other = Request.find_by(
        user_id: params[:other_user_id],
        friend_id: session[:user_id]
      )

      if request_cancel_user.destroy && request_cancel_other.destroy
        logger.info("[info]: 友達リクエストがキャンセルされました。")
        redirect_to other_user_path(session[:user_id], params[:other_user_id])
      else
        flash.now[:message] = "Friend Request Cancel Failed!"
        render("/main/other_user")
      end
  # 友達追加後に削除するための処理
  elsif params[:pending_flg] == "delete"
      request_delete_user = Request.find_by(
        user_id: session[:user_id],
        friend_id: params[:other_user_id]
      )

      request_delete_other = Request.find_by(
        user_id: params[:other_user_id],
        friend_id: session[:user_id]
      )

      friend_delete_user = Friend.find_by(
        user_id: session[:user_id],
        friend_id: params[:other_user_id]
      )

      friend_delete_other = Friend.find_by(
        user_id: params[:other_user_id],
        friend_id: session[:user_id]
      )

      if request_delete_user.destroy && request_delete_other.destroy && friend_delete_user.destroy && friend_delete_other.destroy
        flash.now[:message] = "#{params[:other_user_id]} was deleted from friend list"
        redirect_to friend_list_path(session[:user_id])
      elsif
        flash.now[:message] = "friend deleting was failed"
        render("/main/friend_list")
      end
    end
  end

  def request_list
    ## TODO pending_flgが1,2の場合のみ：一度拒否されたリクエストをどうする??
    # 一定時間がすぎるなどしたら、元に戻る処理を追加する
    # session[:user_id]がリクエストを受け取っている場合
    friend_request = Request.where(user_id: session[:user_id], pending_flg: 2)
    # Request中のfriend_idを格納するリスト
    @request_friends_id_array = []
    # Request中のicon_imageを格納するリスト
    @request_icon_images_array = []

    friend_request.each do |request_info|
      @request_friends_id_array << request_info.friend_id
      @request_icon_images_array << User.find_by(user_id: request_info.friend_id).icon_image
    end
  end

  def request_service
    friend_request_other = Request.find_by(
      user_id: params[:other_user_id],
      friend_id: session[:user_id]
    )

    friend_request_user = Request.find_by(
      user_id: session[:user_id],
      friend_id: params[:other_user_id]
    )
    
    if params[:request_flg] == "accept"
      friend_request_other.pending_flg = 0
      friend_request_user.pending_flg = 0
      # user_id friend_id を相互にDBに保存する
      ######## FIXME friend_flgの処理を追加
      friend_add_my_side = Friend.new(
        user_id: session[:user_id],
        friend_id: params[:other_user_id]
      )
      ######## FIXME friend_flgの処理を追加
      friend_add_other_side = Friend.new(
        user_id: params[:other_user_id],
        friend_id: session[:user_id]
      )
      
      if friend_request_other.save && friend_request_user.save && friend_add_my_side.save && friend_add_other_side.save
        flash.now[:message] = "You and #{friend_request_other.user_id} are friend now!!"
        logger.info("[info]: リクエストを許可しました。")
        redirect_to request_list_path(session[:user_id])
      else
        flash.now[:message] = "Your acceptance was denied"
        logger.info("[info]: リクエストの許可に失敗しました。")
        render("main/request_list")
      end
    elsif params[:request_flg] == "reject"
      if friend_request_other.destroy && friend_request_user.destroy
        flash.now[:message] = "You have Rejected friend request from #{params[:other_user_id]}"
        logger.info("[info]: リクエストを拒否しました。")
        redirect_to request_list_path(session[:user_id])
      else
        flash.now[:message] = "Your rejection was denied"
        logger.info("[info]: リクエストの拒否に失敗しました。")
        render("main/request_list")
      end
    end
  end

  def friend_list
    @friend_accounts = Friend.where(user_id: session[:user_id])
  end
end