$(document).on 'turbolinks:load', ->
  $ ->
    $.extend $.tablesorter.defaults,
      theme: 'bootstrap',
      headerTemplate: '{content} {icon}',
      widgets: ['uitheme']

    $(".tablesorter").tablesorter()
    $(".admin-table").tablesorter()
    return
