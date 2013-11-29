$ ->
  $('.go-to-select select').change () ->
    href = $('option:selected', $(this)).val()
    window.location.href = href if href.length
    true
