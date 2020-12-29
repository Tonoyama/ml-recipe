class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :recipes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :shippings, dependent: :destroy
  has_many :orders
  has_many :cart_items, dependent: :destroy
  has_many :reviews, dependent: :destroy

  attachment :profile_image

  enum is_active: { 退会済: false, 有効: true }
  acts_as_paranoid

  validates :account_name, presence: true, length: { maximum: 15 }
  validates :email, presence: true, uniqueness: true

  has_many :follower, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy # フォロー取得
  has_many :followed, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy # フォロワー取得
  has_many :following_customer, through: :follower, source: :followed # 自分がフォローしている人
  has_many :follower_customer, through: :followed, source: :follower # 自分をフォローしている人

  def follow(customer_id)
    follower.create(followed_id: customer_id)
  end

  def unfollow(customer_id)
    follower.find_by(followed_id: customer_id).destroy
  end

  def following?(customer)
    following_customer.include?(customer)
  end

  def reviewing?(product)
    reviews.exists?(product_id: product.id)
  end
end
