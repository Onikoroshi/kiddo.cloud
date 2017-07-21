module ApplicationHelper

  def flash_class(level)
    level = level.to_sym
    case level
    when :success then "success"
    when :notice then "success"
    when :alert then "info"
    when :info then "info"
    when :warning then "warning"
    when :error then "danger"
    when :danger then "danger"
    end
  end

end
