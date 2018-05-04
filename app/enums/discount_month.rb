class DiscountMonth < ClassyEnum::Base
  def to_i
    0
  end
end

class DiscountMonth::January < DiscountMonth
  def to_i
    1
  end
end

class DiscountMonth::February < DiscountMonth
  def to_i
    2
  end
end

class DiscountMonth::March < DiscountMonth
  def to_i
    3
  end
end

class DiscountMonth::April < DiscountMonth
  def to_i
    4
  end
end

class DiscountMonth::May < DiscountMonth
  def to_i
    5
  end
end

class DiscountMonth::June < DiscountMonth
  def to_i
    6
  end
end

class DiscountMonth::July < DiscountMonth
  def to_i
    7
  end
end

class DiscountMonth::August < DiscountMonth
  def to_i
    8
  end
end

class DiscountMonth::September < DiscountMonth
  def to_i
    9
  end
end

class DiscountMonth::October < DiscountMonth
  def to_i
    10
  end
end

class DiscountMonth::November < DiscountMonth
  def to_i
    11
  end
end

class DiscountMonth::December < DiscountMonth
  def to_i
    12
  end
end
