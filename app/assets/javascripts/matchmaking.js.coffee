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
        $('#matchmacking_status').html(data)

      error: (XMLHttpRequest, testStatus, errorThrown) ->
        alert('Error!')
  ,3000)
