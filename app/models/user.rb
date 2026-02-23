class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, gestor: 1, inquilino: 2 }

  has_many :company_managers, dependent: :destroy
  has_many :companies, through: :company_managers
  has_many :contracts, foreign_key: :tenant_id, dependent: :destroy

  validates :name, :role, presence: true
end
