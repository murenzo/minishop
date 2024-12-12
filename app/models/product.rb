class Product < ApplicationRecord
  belongs_to :seller, class_name: "User"
  has_many :purchases, dependent: :destroy
  has_many :buyers, through: :purchases, class_name: "User"
end
