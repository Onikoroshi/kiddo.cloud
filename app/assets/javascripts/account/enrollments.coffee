updateWeeklyPlan = (elem) ->
  value = elem.val()
  chunks = value.split " to "

  start_str = chunks[0]
  stop_str = chunks[1]

  elem.parent().find(".weekly-starts").val(start_str)
  elem.parent().find(".weekly-ends").val(stop_str)

updateDropIn = (elem) ->
  value = elem.val()

  elem.parent().find(".drop_in-ends").val(value)

  date = new Date(value)
  day_num = date.getUTCDay()

  elem.parent().find(".drop_in-days").val(false)
  elem.parent().find(".drop_in-#{day_num}").val(true)

document.addEventListener 'turbolinks:load', ->
  $(".weekly_select").each ->
    updateWeeklyPlan($(this))

  $(".plan-box").on "change", ".weekly-select", (e) ->
    updateWeeklyPlan($(this))

  $(".drop_in-date-select").each ->
    updateDropIn($(this))

  $(".account-box").on "change", ".drop_in-date-select", (d) ->
    updateDropIn($(this))
