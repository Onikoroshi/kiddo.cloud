document.addEventListener 'turbolinks:load', ->
  Turbolinks.clearCache()
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
    program_id = $("#child-program-switcher").val()

    if location_id
      window.location = "/children/attendance_display?location_id=#{location_id}&program_id=#{program_id}"
    else
      window.location = "/children/attendance_display"
    end
    return

  $("#child-program-switcher").on "change", ->
    program_id = $(this).val()
    location_id = $("#child-location-switcher").val()

    if location_id
      window.location = "/children/attendance_display?location_id=#{location_id}&program_id=#{program_id}"
    else
      window.location = "/children/attendance_display"
    end
    return
