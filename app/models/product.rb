class Product < ApplicationRecord
  belongs_to :user, optional: true

  # ActiveStorage attachment for digital file
  has_one_attached :digital_file

  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :digital_file, presence: true, on: :create

  # Validate file type (PDFs, docs, images, etc.)
  validate :acceptable_file_type

  private

  def acceptable_file_type
    return unless digital_file.attached?

    acceptable_types = [ "application/pdf", "image/png", "image/jpeg", "application/zip",
                        "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ]

    unless acceptable_types.include?(digital_file.content_type)
      errors.add(:digital_file, "must be a PDF, image, ZIP, or DOC file")
    end
  end
end
