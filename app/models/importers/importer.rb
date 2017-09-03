class Importers::Importer

  def clean_cell(row, cell_name)
    value = row[cell_name];
    value = value.to_s
    value = "" if value.nil?
    value = value.strip
    value
  end

end
