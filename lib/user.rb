class User < ActiveRecord::Base
    has_many :userAccounts
    has_many :banks, through: :userAccounts
end