class Gender < ClassyEnum::Base
end

class Gender::Male < Gender
  def subject
    "he"
  end

  def object
    "him"
  end

  def possessive
    "his"
  end

  def possessive_absolute
    "his"
  end
end

class Gender::Female < Gender
  def subject
    "she"
  end

  def object
    "her"
  end

  def possessive
    "her"
  end

  def possessive_absolute
    "hers"
  end
end

class Gender::Nonbinary < Gender
  def subject
    "they"
  end

  def object
    "them"
  end

  def possessive
    "their"
  end

  def possessive_absolute
    "theirs"
  end
end
