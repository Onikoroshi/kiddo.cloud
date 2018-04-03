$(document).ready ->
  $ ->
    $.extend $.tablesorter.defaults,
      theme: 'bootstrap',
      headerTemplate: '{content} {icon}',
      widgets: ['uitheme']

    $(".tablesorter").tablesorter()
    $(".admin-table").tablesorter()
    return
