class Bank < ActiveRecord::Base
    has_many :useraccounts
    has_many :users, through: :useraccounts
end