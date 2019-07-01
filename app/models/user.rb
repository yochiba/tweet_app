class User < ApplicationRecord
    # attr_accessor :user_id
    # attr_accessor :password

    # BCryptの定義
    has_secure_password
    # validation
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :user_id, presence: true, uniqueness: true
    validates :password_digest, presence: true
    validates :icon_image, presence: true
    # def initialize(user_id: user_id, password: password)
    #     @user_id = user_id
    #     @password = password
    # end

    # def login_service

    # end
end
