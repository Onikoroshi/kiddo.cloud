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

  $(".account-box").on "click", ".add-day-button", (e) ->
    # for some reason, adding the new elements doesn't happen *immediately* so attempting to find them was failing. Waiting a very short time resolved this.
    setTimeout (->
      $(".account-box").find(".drop_in-date-select").each ->
        updateDropIn($(this))
    ), 10

  $(".enrollment-pricing-table").on "keyup", ".addable-amount", (event) ->
    elem = $(event.currentTarget)

    charge_total = 0.0
    refund_total = 0.0

    $(".enrollment-pricing-table").find(".addable-amount").each ->
      amount = parseFloat($(this).val().replace(/[^0-9\.\-]/, ""))

      if amount < 0.0
        refund_total += amount * -1
      else
        charge_total += amount

    charge_total = charge_total.toFixed(2)
    refund_total = refund_total.toFixed(2)

    $("#total-charge").text("$#{charge_total}")

    if refund_total > 0
      $("#total-refund").text("$#{refund_total}")
      $("#refund-block").removeClass("hide")
    else
      $("#refund-block").addClass("hide")

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

        if data["total_refund_amount"] > 0
          $("#total-refund").text(data["total_refund_string"])
          $("#refund-block").removeClass("hide")
        else
          $("#refund-block").addClass("hide")

      error: (xhr, status, error) ->

  $(".enrollment-pricing-table").on "change", ".change-fee-requirement", (event) ->
    elem = $(event.currentTarget)
    account_id = elem.data("account-id")
    program_id = elem.data("program-id")
    require_fee = elem.is(':checked')

    $.ajax
      url: "/staff/enrollments/set_change_fee_requirement?account_id=#{account_id}&program_id=#{program_id}&require_fee=#{require_fee}"
      type: "PATCH"
      dataType: 'json'
      headers:
        Accept: "text/javascript, */*; q=0.01"
      success: (data) ->
        amount_div = elem.parent().parent().find(".fee-amount")
        if amount_div.find(".addable-amount").length > 0
          amount_div.find(".addable-amount").val(data["amount"])
        else
          amount_div.text(data["amount"])

        $("#total-charge").text(data["total_charge_amount"])

        if data["total_refund_amount"] > 0
          $("#total-refund").text(data["total_refund_string"])
          $("#refund-block").removeClass("hide")
        else
          $("#refund-block").addClass("hide")

      error: (xhr, status, error) ->
