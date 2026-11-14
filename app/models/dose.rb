class Dose < ApplicationRecord
  belongs_to :child
  belongs_to :medicine
  belongs_to :user

  validates :given_at, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :medicine_belongs_to_child

  scope :newest_first, -> { order(given_at: :desc) }

  private

  def medicine_belongs_to_child
    errors.add(:medicine, "belongs to a different child") if medicine && child && medicine.child_id != child_id
  end
end
