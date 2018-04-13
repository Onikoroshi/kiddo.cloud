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

  $(".enrollment-pricing-table").on "change", ".change-refund-requirement", (event) ->
    elem = $(event.currentTarget)
    change_id = elem.data("change-id")
    require_refund = elem.is(':checked')

    $.ajax
      url: "/staff/enrollments/#{change_id}/set_change_refund_requirement?require_refund=#{require_refund}"
      type: "PATCH"
      dataType: 'json'
      headers:
        Accept: "text/javascript, */*; q=0.01"
      success: (data) ->
        amount_div = elem.parent().parent().find(".refund-amount")
        amount_div.text(data["amount"])
        $("#total-charge").text(data["total_charge_amount"])
        $("#total-refund").text(data["total_refund_amount"])
      error: (xhr, status, error) ->

  $(".enrollment-pricing-table").on "change", ".change-fee-requirement", (event) ->
    elem = $(event.currentTarget)
    account_id = elem.data("account-id")
    require_fee = elem.is(':checked')

    $.ajax
      url: "/staff/enrollments/set_change_fee_requirement?account_id=#{account_id}&require_fee=#{require_fee}"
      type: "PATCH"
      dataType: 'json'
      headers:
        Accept: "text/javascript, */*; q=0.01"
      success: (data) ->
        amount_div = elem.parent().parent().find(".fee-amount")
        amount_div.text(data["amount"])
        $("#total-charge").text(data["total_charge_amount"])
        $("#total-refund").text(data["total_refund_amount"])
      error: (xhr, status, error) ->
