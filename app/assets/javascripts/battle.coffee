playable = true

$ ->
  event = `(window.ontouchstart === undefined)? 'click' : 'touchstart'`
  $('body').on event, (e)->
    if (e.originalEvent.touches)
      position = { x: e.originalEvent.touches[0].pageX, y: e.originalEvent.touches[0].pageY }
    else
      position = { x: e.pageX, y: e.pageY }
    if playable
      App.battle.attack(position)

@game_finish = ()->
  postCanvas()

@game_restart = ()->
  playable = true
  console.log playable

@make_unplayable = ()->
  console.log "make_unplayable"
  playable = false

@make_playable = ()->
  console.log "make_playable"
  playable = true

# Canvasを画像に変換
postCanvas = ()->
  $.when(
    canvas = $('<canvas>')
    canvas.attr 'width', $(window).width()
    canvas.attr 'height', $(window).height()
    ctx = canvas[0].getContext('2d')

    $('.attack-log').each (index, svg_div)->
      image = new Image
      $svg = $(svg_div).find('svg')
      svgData = new XMLSerializer().serializeToString($svg[0]).replace('<path','<path style="fill:' + $svg.find('path').css('fill') + '" ')
      image.onload = ->
        scale = $(svg_div).css('scale')
        $svg.find('path').css('fill')
        ctx.drawImage(image, $svg.offset().left, $svg.offset().top, scale * $svg.width(), scale * $svg.height())
      image.src = "data:image/svg+xml;charset=utf-8;base64," + btoa(unescape(encodeURIComponent(svgData)))

  ).done ->
    setTimeout (->
      data = {}
      canvasData = canvas[0].toDataURL()
      canvasData = canvasData.replace(/^data:image\/png;base64,/, '')
      data.image = canvasData
      $.ajax
        url: '/result'
        type: 'POST'
        async: false
        beforeSend: ()->
        success: (data)->
          $('.win-color').css('background', data[0][0])
          $('.result').fadeIn()
          console.log data[0][0]
          return
        error: (jqXHR, textStatus, errorThrown) ->
          return
        data: data
        dataType: 'json'
    ), 1000
