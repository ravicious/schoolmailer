require "digest"

class Replacement
  include DataMapper::Resource

  property :id, Serial
  property :body, Text, :required => true
  property :body_hash, String
  property :created_at, DateTime
  property :sent, Boolean, :default => false

  validates_presence_of :body
  validates_uniqueness_of :body_hash

  before :valid?, :generate_body_hash

  def self.newest_unmailed
    first(:sent => false, :order => [:created_at.desc])
  end

  def mark_as_sent
    self.sent = true
    save
  end

  private

  def generate_body_hash
    if self.new?
      self.body_hash = Digest::SHA1.hexdigest(self.body) 
    end
  end

end
