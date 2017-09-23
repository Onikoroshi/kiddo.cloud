class ParentsColumnType < ClassyEnum::Base
  def sortable?
    true
  end

  def width_class
    ""
  end

  def for_includes
    "".to_sym
  end

  def field_for_sort(direction)
    ""
  end
end

class ParentsColumnType::PrimaryParent < ParentsColumnType
  def width_class
    "col-xs-2"
  end

  def for_includes
    :primary_parent
  end

  def field_for_sort(direction)
    "parents.last_name #{direction}, parents.first_name #{direction}"
  end
end

class ParentsColumnType::Email < ParentsColumnType
  def width_class
    "col-xs-2"
  end

  def for_includes
    :user
  end

  def field_for_sort(direction)
    "users.email #{direction}"
  end
end

class ParentsColumnType::Children < ParentsColumnType
  def sortable?
    false
  end

  def width_class
    "col-xs-4"
  end
end

class ParentsColumnType::Location < ParentsColumnType
  def width_class
    "col-xs-2"
  end

  def for_includes
    :location
  end

  def field_for_sort(direction)
    "locations.name #{direction}"
  end
end

class ParentsColumnType::Created < ParentsColumnType
  def width_class
    "col-xs-2"
  end

  def field_for_sort(direction)
    "created_at #{direction}"
  end
end
