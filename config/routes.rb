Rails.application.routes.draw do
  # main routes
  root to: 'main#top'
  get 'login', to: 'main#login'
  post 'login', to: 'main#login_service'
  get 'registration', to: 'main#registration'
  post 'registration', to: 'main#registration_service'
  get 'account/:user_id', to: 'main#account'
  get 'account_info/:user_id', to: 'main#account_info'
  put 'account_info/:user_id', to: 'main#account_info_service'
  get 'delete_account/:user_id', to: 'main#delete_account'
  post 'delete_account/:user_id', to: 'main#delete_account_service'
  post 'logout_service', to: 'main#logout_service'
  # main routes friend function
  get 'all_users/:user_id', to: 'main#all_users'
  get 'other_user/:user_id/:other_user_id', to: 'main#other_user'
  post 'other_user/:user_id/:other_user_id/:pending_flg', to: 'main#other_user_service'
  get 'request_list/:user_id', to: 'main#request_list'
  post 'request_list/:user_id/:other_user_id/:request_flg', to: 'main#request_service'
  get 'friend_list/:user_id', to: 'main#friend_list'

  # posts routes
  get 'feed/:user_id', to: 'posts#feed'
  get 'upload/:user_id', to: 'posts#upload'
  post 'upload/:user_id', to: 'posts#upload_service'
  get 'edit/:user_id/:post_id', to: 'posts#edit'
  put 'edit/:user_id/:post_id', to: 'posts#edit_service'
  get 'delete/:user_id/:post_id', to: 'posts#delete'
  delete 'delete/:user_id/:post_id', to: 'posts#delete_service'

  # reactions routes
  post 'like/:user_id/:post_id', to: 'reactions#like'
  delete 'like_cancel/:user_id/:post_id', to: 'reactions#like_cancel'
end
