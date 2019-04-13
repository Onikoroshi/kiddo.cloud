class AddWaiverAgreementsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :mission_statement, :boolean
    add_column :accounts, :program_description, :boolean
    add_column :accounts, :staffing_and_training, :boolean
    add_column :accounts, :holiday_calendar, :boolean
    add_column :accounts, :financial_waiver, :boolean
    add_column :accounts, :behavior_agreement, :boolean
    add_column :accounts, :program_details, :boolean
    add_column :accounts, :liability_waiver, :boolean
    remove_column :accounts, :waiver_agreement
  end
end
