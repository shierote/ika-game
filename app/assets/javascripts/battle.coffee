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

# ゲーム終了時に呼び出された
@game_finish = ()->
  playable = false
  $.when(
    canvas = convertCanvas()
  ).done ->
    postCanvas(canvas)

# Canvasを画像に変換
convertCanvas = ()->
  canvas = $('<canvas>')
  console.log "canvas"
  console.log canvas
  canvas.attr 'width', $(window).width()
  canvas.attr 'height', $(window).height()
  ctx = canvas[0].getContext('2d')
  console.log "ctx"
  console.log ctx

  $('.attack-log').each (index, svg_div)->
    image = new Image
    $svg = $(svg_div).find('svg')
    svgData = new XMLSerializer().serializeToString($svg[0]).replace('<path','<path style="fill:' + $svg.find('path').css('fill') + '" ')
    image.onload = ->
      console.log "インク"
      console.log index
      scale = $(svg_div).css('scale')
      $svg.find('path').css('fill')
      ctx.drawImage(image, $svg.offset().left, $svg.offset().top, scale * $svg.width(), scale * $svg.height())
      console.log '%c+', 'font-size: 10px; height: 50px; width: 50px ; object-fit: cover ;padding: 100px; color: transparent; background-image: url(' + canvas[0].toDataURL() + ');'
      console.log canvas[0].toDataURL()
    image.src = "data:image/svg+xml;charset=utf-8;base64," + btoa(unescape(encodeURIComponent(svgData)))

  console.log '%c+', 'font-size: 10px; height: 50px; width: 50px ; object-fit: cover ;padding: 100px; color: transparent; background-image: url(' + canvas[0].toDataURL() + ');'
  console.log canvas[0].toDataURL()

  canvas

# Canvasの画像データをサーバ側に送りサーバ側で分解、判定
postCanvas = (canvas)->
  data = {}

  canvasData = canvas[0].toDataURL()
  canvasData = canvasData.replace(/^data:image\/png;base64,/, '')
  data.image = canvasData
  console.log canvasData
  console.log "data"
  console.log data
  $.ajax
    url: '/result'
    type: 'POST'
    success: (data)->
      $('.win-color').css('background', data[0][0])
      $('.result').fadeIn()
      console.log data[0][0]
      return
    error: (jqXHR, textStatus, errorThrown) ->
      return
    data: data
    dataType: 'json'
