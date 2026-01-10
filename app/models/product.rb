class Product < ApplicationRecord
  belongs_to :user

  # ActiveStorage attachment for digital file (what customers download)
  has_one_attached :digital_file

  # Product preview image (thumbnail for catalog)
  has_one_attached :image

  validates :title, :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :digital_file, presence: true, on: :create

  # Validate digital file type
  validate :acceptable_digital_file_type

  # Validate image type and size
  validate :acceptable_image

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
