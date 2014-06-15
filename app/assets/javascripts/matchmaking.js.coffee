# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  unless(document.matchmaking_watcher)

    document.matchmaking_watcher = setInterval( ->
      $.ajax
        url: "http://localhost:3001/games/matchmaking_status"
        dataType: 'html'
        cache: false
        success: (data) ->
          reply = JSON.parse(data)
          if(reply.active)
            $('#matchmaking_bar').show()
            $('#matchmaking_status').html(reply.status)
          else
            $('#matchmaking_bar').hide()

        error: (XMLHttpRequest, testStatus, errorThrown) ->
          $('#matchmaking_bar').show()
          $('#matchmaking_status').html('connection problem.')
    ,3000)
