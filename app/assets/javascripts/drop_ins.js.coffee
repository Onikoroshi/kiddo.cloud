document.addEventListener 'turbolinks:load', ->
  Turbolinks.clearCache()
  $('form').on 'cocoon:after-insert', ->
    flatpickr '.flatpickr-date:not([readonly="readonly"]):not([type="hidden"])',
      dateFormat: 'Y-m-d'
      altInput: true
    return
