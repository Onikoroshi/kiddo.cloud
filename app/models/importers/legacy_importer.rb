class Importers::LegacyImporter < Importers::Importer
  require "roo"

  def import
    xls = Roo::Spreadsheet.open("#{Rails.root}/db/extras/RegistrationListReport.xlsx")
    xls.parse(clean: true)
    spreadsheet = xls.sheet(0)
    header = spreadsheet.row(1)
    emails = Array.new
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      emails << clean_cell(row, "Email Address").downcase
    end

    create_users(emails)
  end

  def create_users(emails)
    emails.uniq.each do |email|
      legacy_user = LegacyUser.create(
        email: email,
      )
      puts "Created user #{legacy_user.email}"
    end
  end
end
