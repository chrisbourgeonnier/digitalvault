class Product < ApplicationRecord
  belongs_to :user, foreign_key: :user_id  # Explicit seller link
  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
end
