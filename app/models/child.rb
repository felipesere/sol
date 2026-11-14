class Child < ApplicationRecord
  has_many :medicines, dependent: :destroy
  has_many :doses, dependent: :destroy
  has_many :temperatures, dependent: :destroy

  validates :name, presence: true
end
