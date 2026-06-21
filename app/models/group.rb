require "securerandom"

class Group < ApplicationRecord
  has_many :people, dependent: :destroy
  has_many :availabilities, through: :people
  has_many :events, dependent: :destroy

  before_validation :assign_share_token, on: :create

  validates :name, presence: true
  validates :share_token, presence: true, uniqueness: true

  private

  def assign_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(12)
  end
end
