document.addEventListener("turbolinks:load", function() {
  Turbolinks.clearCache()
  flatpickr('#flatpickr-dob-input', {
    dateFormat: "Y-m-d",
    maxDate: "1-1-2005"
  });

  flatpickr('#flatpickr-input', {
    dateFormat: "Y-m-d",
  });

});
