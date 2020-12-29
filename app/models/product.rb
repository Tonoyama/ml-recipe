class Product < ApplicationRecord
  belongs_to :genre
  has_many :cart_items, dependent: :destroy
  has_many :order_details
  has_many :reviews, dependent: :destroy

  attachment :product_image

  enum is_active: { 売り切れ: false, 販売中: true }

  validates :name, presence: true
  validates :introduction, presence: true
  validates :price, presence: true
  validates :price, numericality: { greater_than: 0 }, if: proc { |s| s.price.present? }
end
