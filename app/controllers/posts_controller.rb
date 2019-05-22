class PostsController < ApplicationController
  def feed
    @posts = Post.all.order(updated_at: :desc)

  end

  def upload

  end

  def upload_service
    isRender_flag = true
    post_info = Post.new(
      user_id: session[:user_id]
    )
    post_info.save!
    # validetionによって、post_idの取得ができないので、validation off のelse renderで対処
    if params[:post_image]
      logger.info("id = #{post_info.id}")
      post_image = params[:post_image]
      File.binwrite("public/post_images/#{post_info.id}.jpg", post_image.read)
      post_info.image = "#{post_info.id}.jpg"
      logger.info("[info]: imageが作成されました。")
    else
      isRender_flag = false
      logger.info("[info]: render flag")
    end

    if params[:content_text] 
      content_text = params[:content_text]
      if content_text.empty? || content_text.nil? || content_text.blank?
        isRender_flag = false
        logger.info("[info]: render flag")
      else
        post_info.content_text = params[:content_text]
        logger.info("[info]: content_textが作成されました。")
      end
    else
      isRender_flag = false
      logger.info("[info]: render flag")
    end

    if post_info.save && isRender_flag
      logger.info("[info]: redirectが成功しました。")
      redirect_to("/feed/#{session[:user_id]}")
    else
      post_info.destroy!
      logger.info("[info]: imageまたはcontent_textが未入力のためpost_infoはdestroyされました。")
      flash[:message] = "image or text is blank!"
      logger.info("[info]: renderされました。")
      render("/posts/upload")
    end
  end

  def edit
    @posted_info = Post.find_by(id: params[:post_id], user_id: session[:user_id])
  end

  def edit_service
    post_info = Post.find_by(id: params[:post_id], user_id: session[:user_id])
    post_info.content_text = params[:edited_text]
    post_info.save!
    if post_info.save!
      flash[:message] = "Editting was succeed!"
      redirect_to("/feed/#{session[:user_id]}")
    else
      flash[:message] = "Edit faild! Try again!"
      render("/edit/#{session[:user_id]}/#{params[:post_id]}")
    end
  end

  def delete
  end

  def delete_service
    reactions = Reaction.where(post_id: params[:post_id])
    # delete_flag 1 -> 2 論理削除
    reactions.each do |reaction|
      logger.info("[info]: #{reaction}")
      reaction.d_flag = 2
      if reaction.save!
        logger.info("[info]: delete_flagを変更し、reactionを論理削除しました。")
      else
        render("posts/delete/#{session[:user_id]}/#{params[:post_id]}")
      end
    end
    post_info = Post.find_by(id: params[:post_id], user_id: session[:user_id])
    post_info.destroy!
    redirect_to("/feed/#{session[:user_id]}")
  end
end
