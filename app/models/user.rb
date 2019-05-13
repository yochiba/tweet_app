class User < ApplicationRecord
    # BCryptの定義
    has_secure_password
    # validation
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :user_id, presence: true
    validates :password_digest, presence: true
    validates :icon_image, presence: true

    # cache handling
    # def self.cache_account
    #     Rails.cache.fetch("account_info"){User.all}
    # end
end
