class Bank < ActiveRecord::Base
    has_many :userAccounts
    has_many :users, through: :userAccounts
end