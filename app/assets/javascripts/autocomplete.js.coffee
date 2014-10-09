$ ->
  $('.need_autocomplete.for_emails').autocomplete({
    source: '/users/search'
    delay: 200
    select: (evt, ui) ->
      $('#permission_user_id').val(ui.item.id)
      $('.for_email').val(ui.item.label)
  })

