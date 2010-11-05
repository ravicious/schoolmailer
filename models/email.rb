class Email
  include DataMapper::Resource

  property :address, String, :key => true, :format => :email_address
  property :confirmation_hash, String, :writer => :protected
  property :confirmed, Boolean, :default => false, :writer => :protected
  property :queued, Boolean, :default => false, :writer => :protected

  before :create, :generate_confirmation_hash
  validates_uniqueness_of :address

  def self.activated
    all(:confirmed => true)
  end

  def self.unactivated
    all(:confirmed => false)
  end

  def confirm(submitted_hash)
    # !confirmed - nie aktywuj maila, jeśli jest już on aktywowany
    if (submitted_hash == confirmation_hash and !confirmed)
      attribute_set(:confirmed, true)
      save
    else
      false
    end
  end

  def move_to_queue
    attribute_set(:queued, true)
  end

  def unsubscribe(submitted_hash)
    # confirmed - nie usuwaj maila z subskrypcji, jeśli jest on już nieaktywny
    if (submitted_hash == confirmation_hash and confirmed)
      destroy
    else
      false
    end
  end

  private

  def generate_confirmation_hash
    attribute_set(:confirmation_hash, Digest::SHA1.hexdigest(address + Time.now.to_s + rand(100000).to_s))
  end

end
