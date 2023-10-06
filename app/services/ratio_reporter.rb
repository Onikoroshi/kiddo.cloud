class RatioReporter
  attr_reader :time_entries_array

  def initialize(time_entries_relation)
    @time_entries_array = time_entries_relation.reorder(:time).pluck(:time_recordable_type, :time_recordable_id, :time, :record_type)
    # [
    #   [
    #     0 => time_recordable_type - "Staff" or "Child"
    #     1 => time_recordable_id,
    #     2 => time
    #     3 => record_type - blank, "entry", or "exit"
    #   ],
    # ]
  end

  def ratio_report
    return {} if time_entries_array.empty?

    checked_in = {
      "Staff" => [],
      "Child" => []
    }

    report = {}

    current_time_chunk = find_first_fifteen(time_entries_array.first[2])

    time_entries_array.each do |entry_data|
      entry_time = entry_data[2].in_time_zone

      if entry_time > current_time_chunk
        report[current_time_chunk.stamp("3:00 PM")] = {
          "staff_count" => checked_in["Staff"].count,
          "children_count" => checked_in["Child"].count
        }

        current_time_chunk += 15.minutes
      end

      record_type = entry_data[3]
      recordable_type = entry_data[0]
      recordable_id = entry_data[1]

      if record_type == "entry"
        checked_in[recordable_type] << recordable_id if !checked_in[recordable_type].include?(recordable_id)
      else # blank or "exit"
        checked_in[recordable_type].delete(recordable_id)
      end
    end

    report[current_time_chunk.stamp("3:00 PM")] = {
      "staff_count" => checked_in["Staff"].count,
      "children_count" => checked_in["Child"].count
    }

    report
  end

  # find the first 15 minute chunk that is *after* the first entry.
  # so if the first entry is at 4:13, this will return 4:15
  def find_first_fifteen(first_time)
    first_time.at_beginning_of_hour + (first_time.min - first_time.min % 15).minutes + 15.minutes
  end
end
