require "securerandom"

class Person < ApplicationRecord
  PALETTE = %w[
    #a8323e #d57a35 #d5b45f #5f8f7a #4b7aa0 #8a5fa0
  ].freeze

  belongs_to :group
  has_many :availabilities, dependent: :destroy
  has_many :event_participants, dependent: :destroy
  has_many :events, through: :event_participants

  before_validation :assign_default_color

  validates :name, presence: true
  validates :color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/ }

  def initials
    name.to_s.split.filter_map { |part| part[0] }.join[0, 2].to_s.upcase
  end

  private

  def assign_default_color
    self.color = PALETTE[SecureRandom.random_number(PALETTE.length)] if color.blank?
  end
end
