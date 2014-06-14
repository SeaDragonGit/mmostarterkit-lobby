# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  setInterval( ->
    $.ajax
      url: "http://localhost:3001/games/matchmaking_status"
      dataType: 'html'
      cache: false
      success: (data) ->
        reply = JSON.parse(data)
        if(reply.active)
          $('#matchmacking_status').show()
          $('#matchmacking_status').html(reply.status)
        else
          $('#matchmacking_status').hide()

      error: (XMLHttpRequest, testStatus, errorThrown) ->
        $('#matchmacking_status').show()
        $('#matchmacking_status').html('connection problem.')
  ,3000)
