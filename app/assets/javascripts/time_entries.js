$('#user_list').change(function() {
  window.location = $(this).find(":selected").data('edit-url');
}