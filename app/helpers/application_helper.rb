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

# monkey patch shopify/money class to properly display monetary amounts
class Money
  def to_s
    pre = value < 0 ? "-$" : "$"

    index = -7
    result = sprintf("%.2f", value.to_f.abs)
    while (result.length + index) >= 0 do
      result.insert(index, ",")
      index -= 4
    end
    pre + result
  end
end
