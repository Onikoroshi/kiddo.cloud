document.addEventListener 'turbolinks:load', ->
  Turbolinks.clearCache()
  $('form').on 'cocoon:after-insert', ->
    flatpickr '#flatpickr-input',
      dateFormat: 'Y-m-d'
    return

