class DrawnNumber
  include DataMapper::Resource

  property :id, Serial
  property :value, Integer, :required => true
  property :created_at, DateTime
  property :sent, Boolean, :default => false

  validates_presence_of :value

  def self.newest_unmailed
    first(:sent => false, :order => [:created_at.desc])
  end

  def mark_as_sent
    self.sent = true
    save
  end

end
