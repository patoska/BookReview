class Book < ApplicationRecord
  validates :title, presence: true, uniqueness: true
end
