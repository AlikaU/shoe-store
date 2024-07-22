class Sale < ApplicationRecord
  validates :model, presence: true, length: { minimum: 1 }
  validates :store, presence: true, length: { minimum: 1 }
end
