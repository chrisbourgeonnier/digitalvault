class Order < ApplicationRecord
  belongs_to :user

  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending paid failed cancelled] }
  validates :stripe_session_id, uniqueness: true, allow_nil: true

  # Store cart items as JSON (simple approach for MVP)
  serialize :cart_data, coder: JSON
end
