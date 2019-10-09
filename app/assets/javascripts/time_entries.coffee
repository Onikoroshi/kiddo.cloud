# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  $(".staff-time-entries").on "change", ".clock-toggle", (event) ->
    elem = $(event.currentTarget)
    location_id = elem.data("locationId")
    time_recordable_id = elem.data("timeRecordableId")
    time_recordable_type = elem.data("timeRecordableType")

    on_clock = elem.is(':checked')
    clock_str = ""
    if on_clock
      clock_str = "on_clock=true&"

    pin_number_elem = $("#pin_number_#{time_recordable_id}")
    pin_number = pin_number_elem.val()

    $.ajax
      url: "/time_entries?#{clock_str}time_entry%5Blocation_id%5D=#{location_id}&time_entry%5Btime_recordable_id%5D=#{time_recordable_id}&time_entry%5Btime_recordable_type%5D=#{time_recordable_type}&pin_number=#{pin_number}"
      type: "POST"
      dataType: 'json'
      headers:
        Accept: "text/javascript, */*; q=0.01"
      success: (data) ->
        console.log("success!")

        pin_number_elem.val("")
        elem.prop('checked', data["clocked_in"])
      error: (xhr, status, error) ->
        console.log(xhr)
        console.log(status)
        console.log(error)

        elem.prop('checked', !on_clock)

        if xhr.responseText == "PIN Number Incorrect"
          console.log("xhr response #{xhr.responseText} correct")

          error_div = $("#pin_error_#{time_recordable_id}")
          error_div.show()
        else
          console.log("xhr response #{xhr.responseText} incorrect")
