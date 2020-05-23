class User < ActiveRecord::Base
    has_many :useraccounts
    has_many :banks, through: :useraccounts
end