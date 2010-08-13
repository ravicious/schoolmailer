class Email
  include DataMapper::Resource

  property :address, String, :key => true, :format => :email_address
  property :confirmation_hash, String, :accessor => :protected
  property :confirmed, Boolean, :default => false, :writer => :protected

  before :create, :generate_confirmation_hash
  validates_uniqueness_of :address

  def self.activated
    all(:confirmed => true)
  end

  def self.unactivated
    all(:confirmed => false)
  end

  private

  def generate_confirmation_hash
    attribute_set(:confirmation_hash, Digest::SHA1.hexdigest(address + Time.now.to_s + rand(100000).to_s))
  end

end
