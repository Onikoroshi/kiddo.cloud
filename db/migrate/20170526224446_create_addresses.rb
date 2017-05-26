class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :extended
      t.string :locality
      t.string :region
      t.string :postal_code
      t.string :country_code_alpha3
      t.string :phone
      t.string :url
      t.float :longitude
      t.float :latitude
      t.references :addressable, polymorphic: true

      t.timestamps
    end
    add_index :addresses, [:addressable_id, :addressable_type], :unique => true
  end
end
