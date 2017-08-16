class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :program
end
