class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  def full_address
    [street, locality, region, postal_code, country_code].compact.reject {|s| s.blank?}.join(", ")
  end
end


