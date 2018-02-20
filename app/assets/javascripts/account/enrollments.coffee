document.addEventListener 'turbolinks:load', ->
  $(".plan-box").on "change", ".weekly-select", (e) ->
    value = $(this).val()
    chunks = value.split " to "

    start_str = chunks[0]
    stop_str = chunks[1]

    $(this).parent().find(".weekly-starts").val(start_str)
    $(this).parent().find(".weekly-ends").val(stop_str)

  $(".account-box").on "change", ".drop_in-date-select", (d) ->
    value = $(this).val()

    $(this).parent().find(".drop_in-ends").val(value)

    date = new Date(value)
    day_num = date.getUTCDay()

    $(this).parent().find(".drop_in-days").val(false)
    $(this).parent().find(".drop_in-#{day_num}").val(true)
