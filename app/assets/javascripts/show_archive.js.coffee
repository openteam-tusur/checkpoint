$ ->
  $('.periods_list a.archive').on 'click', ->
    link = $(this)
    $('.periods_list .closed').slideToggle('fast')
    link.toggleClass('toggle_up').toggleClass('toggle_down')
    false
  true
