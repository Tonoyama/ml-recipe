class Ingredient < ApplicationRecord
  belongs_to :recipe
  acts_as_list scope: :recipe

  validates :content, presence: true, length: { maximum: 20 }
  validates :amount, presence: true, length: { maximum: 10 }
end
