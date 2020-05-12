class Message < ApplicationRecord

  belongs_to :inbox
  belongs_to :outbox

  def current?
    self.created_at >= 1.week.ago
  end

  def stale?
    self.created_at < 1.week.ago
  end

  def unread?
    self.read == false
  end

  def mark_as_read
    self.update_attribute(:read, true)
  end
end