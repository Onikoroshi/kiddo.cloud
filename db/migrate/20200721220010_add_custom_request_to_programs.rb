class AddCustomRequestToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :custom_requests, :boolean, default: false
    add_column :programs, :custom_requests_url, :string, default: ""
  end
end
