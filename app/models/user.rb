class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  #before_save :validate_model
  validates :name, presence: true

  has_many :accounts, class_name: "BankAccount", :foreign_key => 'owner_id'

  #private

  #def validate_model
  #  errors.add(:name, "Name is required") if self.name.blank?
  #end

end
