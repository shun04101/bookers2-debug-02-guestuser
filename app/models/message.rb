class Message < ApplicationRecord
  validates :centent, presence: true
  belongs_to :user
  belongs_to :room

end
