#= require active_admin/base
#= require moment

$( ->
  # Format day of week on Meal index page
  $('td.col-date').each( (index) ->
    if $(this).text()
      $(this).text(moment(new Date($(this).text())).format('ddd, MMM D YYYY'))
  )


  # Format day of week on Bill index page
  $('td.col-meal').each( (index) ->
    if $(this).text()
      $(this).text(moment(new Date($(this).text())).format('ddd, MMM D YYYY'))
  )


  # Add day of week to options on Bill edit page
  $('#bill_meal_id option').each( (index) ->
    if $(this).text()
      $(this).text(moment(new Date($(this).text())).add(1, 'days').format('ddd, MMM D YYYY'))
  )


  # Bring name field into focus when adding a new unit
  if window.location.pathname == '/units/new'
    $('#unit_name').focus()


  # Bring name field into focus when adding a new resident
  if window.location.pathname == '/residents/new'
    $('#resident_name').focus()


  # Clear bill amount if it's 0
  if $('#bill_amount_decimal').val() == '0.0'
    $('#bill_amount_decimal')
      .val('')

  # Make the damn remember me checkbox default checked
  $('#admin_user_remember_me').prop('checked', true)

  # Change Communities to Community
  if $("#page_title").html() is "Communities"
    $("#page_title").html("Community")

  # Make Date columns a little wider
  $('.col-date').css('min-width', '150px')

  # Let People Know This is the Admin Page
  if window.location.pathname == "/login"
    $("body").prepend("<h3 style='margin-left:auto;margin-right:auto;width:150px'>Admin Login</h3>")
    $("body").prepend("<a href='#{window.location.protocol}//comeals.#{window.location.hostname.split(".")[2]}/'>Normal Login</a>")
)
