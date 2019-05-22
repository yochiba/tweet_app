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

  # 友達機能関連
  def all_users
    @accounts_list = User.all.where.not(user_id: session[:user_id])

    @friend_request = Request.find_by(
      user_id: session[:user_id],
      friend_id: params[:other_user_id]
    )
    @pending_flg = 0
    if @friend_request == nil
      logger.info("[info]: nilです！")
    elsif @friend_request.pending_flg == 1
      @pending_flg = 1
      logger.info("[info]: pending_flg = #{@friend_request.pending_flg}")
    end
  end

  def other_user
    @relationship_flg = 0
    @other_user = User.find_by(user_id: params[:other_user_id])
    @friend_my_side = Friend.find_by(
      user_id: session[:user_id],
      friend_id: params[:other_user_id]
    )
    @friend_other_side = Friend.find_by(
      user_id: params[:other_user_id],
      friend_id: session[:user_id]
    )
    # リクエストを送受信を判別する処理
    friend_request = Request.find_by(
      user_id: session[:user_id], #aa
      friend_id: params[:other_user_id], #bb
    )
    # relationship_flg
    # 0: 初期値
    # 1: すでに友達
    # 2: 自分がリクエストを送信中(pending)
    # 3: 相手からリクエストあり(test)
    # FIXME 片方がrelationship_flg = 1にならない。
    if @friend_my_side != nil && @friend_other_side != nil
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
      @friend_request_my_side = Request.new(
        user_id: session[:user_id],
        friend_id: params[:other_user_id],
        pending_flg: 1
      )

      @friend_request_other_side = Request.new(
        user_id: params[:other_user_id],
        friend_id: session[:user_id],
        pending_flg: 2
      )

      if @friend_request_my_side.save! && @friend_request_other_side.save!
        redirect_to("/other_user/#{session[:user_id]}/#{params[:other_user_id]}")
      else
        flash[:message] = "Friend Request Failed!"
        render("/main/all_users/#{session[:user_id]}")
      end
    elsif params[:pending_flg] == "cancel"
      @friend_request_my_side = Request.find_by(
        user_id: session[:user_id],
        friend_id: params[:other_user_id]
      )
      @friend_request_other_side = Request.find_by(
        user_id: params[:other_user_id],
        friend_id: session[:user_id]
      )

      if @friend_request_my_side.destroy! && @friend_request_other_side.destroy!
        logger.info("[info]: 友達リクエストがキャンセルされました。")
        redirect_to("/other_user/#{session[:user_id]}/#{params[:other_user_id]}")
      else
        flash[:message] = "Friend Request Cancel Failed!"
        render("/main/other_user/#{session[:user_id]}")
      end
    end
  end

  def request_list
    # FIXME pending_flgが1,2の場合のみ：一度拒否されたリクエストをどうする??
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
    # Requestのpending_flg 0->already friend, 1->pending, 2->rejected
    if params[:request_flg] == "accept"
      friend_request_other.pending_flg = 0
      friend_request_user.pending_flg = 0
      # user_id friend_id を相互にDBに保存する
      ## FIXME friend_flgの処理を追加
      friend_add_my_side = Friend.new(
        user_id: session[:user_id],
        friend_id: params[:other_user_id]
      )
      ## FIXME friend_flgの処理を追加
      friend_add_other_side = Friend.new(
        user_id: params[:other_user_id],
        friend_id: session[:user_id]
      )
      
      if friend_request_other.save! && friend_request_user.save! && friend_add_my_side.save! && friend_add_other_side.save!
        flash[:message] = "You and #{friend_request_other.user_id} are friend now!!"
        logger.info("[info]: リクエストを許可しました。")
        redirect_to("/request_list/#{session[:user_id]}")
      elsif
        flash[:message] = "Your acceptance was denied"
        logger.info("[info]: リクエストの許可に失敗しました。")
        render("main/request_list/#{session[:user_id]}")
      end
    elsif params[:request_flg] == "reject"
      # FIXME 次のアップデートで拒否後の処理を追加
      # friend_request_other.pending_flg = 4
      # friend_request_user.pending_flg = 4
      # FIXME flash[:message] 本来は以下のif文内　応急処置中
      flash[:message] = "You have Rejected friend request from #{friend_request_other.user_id}"
      if friend_request_other.destroy! && friend_request_user.destroy!
        logger.info("[info]: リクエストを拒否しました。")
        redirect_to("/request_list/#{session[:user_id]}")
      else
        flash[:message] = "Your rejection was denied"
        logger.info("[info]: リクエストの拒否に失敗しました。")
        render("main/request_list/#{session[:user_id]}")
      end
    end
  end

  def friend_list
    @icon
    @friend_accounts = Friend.where(user_id: session[:user_id])
  end
end
