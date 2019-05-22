class ReactionsController < ApplicationController
  def like
    @like = Reaction.new(
      user_id: session[:user_id],
      post_id: params[:post_id]
    )
    if @like.save!
      redirect_to("/feed/#{session[:user_id]}")
    else
      render("/posts/feed/#{session[:user_id]}")
    end
  end

  def like_cancel
    @like = Reaction.find_by(
      user_id: session[:user_id],
      post_id: params[:post_id]
    )
    @like.destroy!
    redirect_to("/feed/#{session[:user_id]}")
  end
end
