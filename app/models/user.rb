class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Seller
  has_many :products, foreign_key: :seller_id, dependent: :destroy
  # Buyer
  has_many :purchases, foreign_key: :buyer_id, dependent: :destroy

  def has_purchased?(product)
    purchases.where(product_id: product.id).any?
  end
end
