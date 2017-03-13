require 'digest/sha2'

class User < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :password, :confirmation => true
  attr_accessor :password_cofirmation
  attr_reader   :password

  #validates :password_must_be_present

  def User.encrypt_password(passwrod, salt)
    Digest::SHA2.hexdigest(passwrod + "wibble" + salt)
  end

  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def password=(password)
    @password = password
    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  def User.authenticate(name, password)
    if user = find_by(name)
      if user.hashed_password == encrypt_password(password, user.salt)
        user
      end
    end
  end
  private
  def password_must_be_present
    error.add(:password, "Missing password") unless hashed_password.present?
  end
  after_destroy :ensure_an_admin_remains
  def ensure_an_admin_remains
    if User.count.zero?
      railse "Can't delete last user"
    end
  end

end
