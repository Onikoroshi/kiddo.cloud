class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :program

  def itemization_total
    total = 0.00
    itemizations.each do |_k, v|
      total += v.to_f
    end
    total
  end
end
