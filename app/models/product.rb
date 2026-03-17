class Product < ApplicationRecord
  belongs_to :user

  # Many-to-many relationship with categories
  has_and_belongs_to_many :categories

  # ActiveStorage attachment for digital file (what customers download)
  has_one_attached :digital_file

  # Product preview image (thumbnail for catalog)
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 400, 300 ], strip: true, quality: 85
  end

  validates :title, :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :digital_file, presence: true, on: :create

  # Validate digital file type
  validate :acceptable_digital_file_type

  # Validate image type and size
  validate :acceptable_image

  # Scopes for filtering and searching
  scope :search_by_keyword, ->(keyword) {
    where("title ILIKE ? OR description ILIKE ?", "%#{keyword}%", "%#{keyword}%") if keyword.present?
  }

  scope :min_price, ->(price) {
    where("price >= ?", price.to_f) if price.present?
  }

  scope :max_price, ->(price) {
    where("price <= ?", price.to_f) if price.present?
  }

  scope :sorted_by, ->(sort_option) {
    case sort_option.to_s
    when "oldest"
      order(created_at: :asc)
    when "price_asc"
      order(price: :asc)
    when "price_desc"
      order(price: :desc)
    else # "newest" or default
      order(created_at: :desc)
    end
  }

  # Filter by category
  scope :by_category, ->(category_id) {
    joins(:categories).where(categories: { id: category_id }) if category_id.present?
  }

  # Image helpers for views
  def image_thumb_url
    image.variant(:thumb).processed.url if image.attached?
  end

  def image_original_url
    image.url if image.attached?
  end

  private

  def acceptable_digital_file_type
    return unless digital_file.attached?

    acceptable_types = [ "application/pdf", "image/png", "image/jpeg", "image/jpg", "application/zip",
                        "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ]

    unless acceptable_types.include?(digital_file.content_type)
      errors.add(:digital_file, "must be a PDF, image, ZIP, or DOC file")
    end
  end

  def acceptable_image
    return unless image.attached?

    # Check file type
    acceptable_types = [ "image/png", "image/jpeg", "image/jpg", "image/gif", "image/webp" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a PNG, JPG, GIF, or WebP image")
    end

    # Check file size (5MB limit)
    if image.byte_size > 5.megabytes
      errors.add(:image, "must be less than 5MB")
    end
  end
end
