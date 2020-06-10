class Organization < ApplicationRecord
  has_many :users
  has_many :servers
  has_one  :admin, class_name: User, required: true
end
