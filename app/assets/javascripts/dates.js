document.addEventListener("turbolinks:load", function() {
  Turbolinks.clearCache()
  flatpickr('#flatpickr-dob-input', {
    dateFormat: "m-d-Y",
    maxDate: "1-1-2005"
  });

  flatpickr('#flatpickr-input', {
    dateFormat: "m-d-Y",
  });
});
