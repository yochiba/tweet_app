Rails.application.routes.draw do
  # main routes
  get '/', to: 'main#top'
  get 'login', to: 'main#login'
  post 'login', to: 'main#login_service'
  get 'registration', to: 'main#registration'
  post 'registration', to: 'main#registration_service'
  get 'account/:user_id', to: 'main#account'
  get 'account_info/:user_id', to: 'main#account_info'
  post 'account_info/:user_id', to: 'main#account_info_service'
  post 'logout_service', to: 'main#logout_service'

  # posts routes
  get 'feed/:user_id', to: 'posts#feed'
  get 'upload/:user_id', to: 'posts#upload'
  post 'upload/:user_id', to: 'posts#upload_service'
  get 'edit/:user_id/:post_id', to: 'posts#edit'
  post 'edit/:user_id/:post_id', to: 'posts#edit_service'
  get 'delete/:user_id/:post_id', to: 'posts#delete'
  post 'delete/:user_id/:post_id', to: 'posts#delete_service'

  # reactions routes
  post 'like/:user_id/:post_id', to: 'reactions#like'
  post 'like_cancel/:user_id/:post_id', to: 'reactions#like_cancel'

end
