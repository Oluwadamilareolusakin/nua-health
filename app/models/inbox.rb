class Inbox < ApplicationRecord

  belongs_to :user
  has_many :messages

  def unread?
    messages.where(read: false).size
  end

  def read?
    messages.where(read: true).size
  end
end