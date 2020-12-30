class Recipe < ApplicationRecord
  acts_as_taggable
  is_impressionable

  belongs_to :customer
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :cookings, -> { order(position: :asc) }, dependent: :destroy
  has_many :ingredients, -> { order(position: :asc) }, dependent: :destroy

  attachment :recipe_image

  enum recipe_status: { レシピ: 0, 材料: 1, 作り方: 2, 完成: 3, 未入力あり: 4, 準備中: 5 }

  validates :title, presence: true, length: { maximum: 30 }
  validates :introduction, presence: true, length: { maximum: 200 }
  validates :amount, presence: true, length: { maximum: 30 }

  def favorited_by?(customer)
    favorites.where(customer_id: customer.id).exists?
  end
end
