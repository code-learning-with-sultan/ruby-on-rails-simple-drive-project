class Document < ApplicationRecord
  self.primary_key = "id"

  # Validations
  validates :id, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "only allows alphanumeric characters, hyphens, and underscores" }
  validates :file_data, presence: true
end
