$ ->
  $("#staff-location-switcher").on "change", ->
    location_id = $(this).val()
    if location_id
      window.location = "/staff/attendance_display?location_id=#{location_id}"
    else
      window.location = "/staff/attendance_display"
    end
    return

  $("#child-location-switcher").on "change", ->
    location_id = $(this).val()
    if location_id
      window.location = "/children/attendance_display?location_id=#{location_id}"
    else
      window.location = "/children/attendance_display"
    end
    return


