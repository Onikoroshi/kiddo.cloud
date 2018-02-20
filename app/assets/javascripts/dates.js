document.addEventListener("turbolinks:load", function() {
  Turbolinks.clearCache()
  flatpickr('#flatpickr-dob-input', {
    dateFormat: "Y-m-d",
    defaultDate: "1-1-2007",
    altInput: true
  });

  flatpickr('.flatpickr-input', {
    dateFormat: "Y-m-d",
    altInput: true
  });

});
