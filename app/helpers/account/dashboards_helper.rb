module Account::DashboardsHelper
  def parents_column_path(column_type, params)
    if column_type.sortable?
      staff_accounts_path(sort: column_type, sort_dir: ((params[:sort] != column_type.to_s) || (params[:sort_dir] == "desc")) ? "asc" : "desc")
    else
      "#"
    end
  end

  def parents_column_icon(column_type, params)
    if params[:sort] == column_type.to_s
      params[:sort_dir] == "asc" ? "keyboard_arrow_down" : "keyboard_arrow_up"
    else
      ""
    end
  end
end
