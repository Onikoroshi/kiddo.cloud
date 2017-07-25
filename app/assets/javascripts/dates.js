document.addEventListener("turbolinks:load", function() {
  flatpickr('#flatpickr-input', {
    dateFormat: "d-m-Y",
    maxDate: "1-1-2000"
  });
});
