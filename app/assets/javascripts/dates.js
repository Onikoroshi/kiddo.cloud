document.addEventListener("turbolinks:load", function() {
  Turbolinks.clearCache()
  flatpickr('.flatpickr-date', {
    dateFormat: "Y-m-d",
    altInput: true
  });

  flatpickr('.flatpickr-datetime', {
    altInput: true,
    enableTime: true
  });
});
