class Category < ApplicationRecord
  has_and_belongs_to_many :products

  validates :name, presence: true, uniqueness: true

  # Scope to order categories alphabetically
  scope :ordered, -> { order(name: :asc) }
end
