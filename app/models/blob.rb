class Blob < ApplicationRecord
  # Set the primary key for the model
  self.primary_key = "id"

  # Validations
  validates :id, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "only allows alphanumeric characters, hyphens, and underscores" }
  validates :size, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
