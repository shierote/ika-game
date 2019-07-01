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
  canvas = convertCanvas()
  postCanvas(canvas)

# Canvasを画像に変換
convertCanvas = ()->
  canvas = $('<canvas>')
  canvas.attr 'width', $(window).width()
  canvas.attr 'height', $(window).height()
  ctx = canvas[0].getContext('2d')

  # ここら辺でバグの可能性もある
  $('.attack-log').each (index, svg_div)->
    console.log "インク"
    console.log index
    scale = $(svg_div).css('scale')
    $svg = $(svg_div).find('svg')
    $svg.find('path').css('fill')
    svgData = new XMLSerializer().serializeToString($svg[0]).replace('<path','<path style="fill:' + $svg.find('path').css('fill') + '" ')
    image = new Image
    image.src = "data:image/svg+xml;charset=utf-8;base64," + btoa(unescape(encodeURIComponent(svgData)))
    console.log '%c+', 'font-size: 10px; height: 50px; width: 50px ; object-fit: cover ;padding: 100px; color: transparent; background-image: url(' + image.src + ');'
    ctx.drawImage(image, $svg.offset().left, $svg.offset().top, scale * $svg.width(), scale * $svg.height())
    console.log "canvas"
    console.log canvas

  canvas

# Canvasの画像データをサーバ側に送りサーバ側で分解、判定
postCanvas = (canvas)->
  data = {}

  # ここら辺でバグってる気がする
  console.log "canvas"
  canvasData = canvas[0].toDataURL()
  console.log canvasData
  console.log '%c+', 'font-size: 10px; height: 50px; width: 50px ; object-fit: cover ;padding: 100px; color: transparent; background-image: url(' + canvasData + ');'
  canvasData = canvasData.replace(/^data:image\/png;base64,/, '')
  data.image = canvasData
  $.ajax
    url: '/result'
    type: 'POST'
    success: (data)->
      $('.win-color').css('background', data[0][0])
      $('.result').fadeIn()
      return
    error: (jqXHR, textStatus, errorThrown) ->
      return
    data: data
    dataType: 'json'
