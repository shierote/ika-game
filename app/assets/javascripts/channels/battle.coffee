my_color = ""
my_uuid = ""
actions = {}

intervalID = ""
timeoutID = ""
# ゲーム時間のカウントダウンタイマー
count_down = ()->
  sec = $('.timer').text() - 1
  $('.timer').text sec
  if 0 == sec
    clearInterval intervalID
    $('.timer-unit').hide()

# スタート前のカウントダウンタイマー
start_count_down = ()->
  sec = $('.timer').text() - 7
  $('.timer').text sec
  if 0 == sec
    clearInterval intervalID
    $('.timer-unit').hide()

# スタート開始のアニメーション
start_animation = ()->
  $('.start').transition({ display: 'block', scale: 100 }, 0)
  .transition({ scale: 1 }, 250, 'snap')
  .transition({ opacity: 0 }, 1000, 'ease')

# BattleChannelに接続、挙動を定義
App.battle = App.cable.subscriptions.create "BattleChannel",
  # 接続が確立したとき
  connected: ->
    # controller側のBattleChannel#joinを呼び出す（#joinで下記に定義されたactions['join']を呼び出す）
    @perform 'join'

  # 接続が切れたとき
  disconnected: ->

  # subscriberから流れてきたデータを受信したときに発火
  received: (data) ->
    console.log "data.action is below"
    console.log data.action
    actions[data.action](data, this)

  # インクを飛ばす
  attack: (position) ->
    # インクの形は毎回ランダムできまる
    ink_type = Math.floor( Math.random() * 12) + 1
    @perform 'attack', position: position, color: my_color, ink_type: ink_type

  # Rails側でstartが呼び出されたら発火
  start: () ->
    @perform 'start'

# join
actions['join'] = (data)->
  console.log "join is called:coffee"
  $('.waiting').hide()
  my_color = data.color
  my_uuid = data.uuid
  $('.uuid').text(data.uuid)
  $('.color').addClass(my_color)
  my_avatar = $('#avatar-' + data.avatar).clone()
  my_avatar.attr('id', '')
  my_avatar.css('position', 'absolute')
  my_avatar.css('top', 20)
  my_avatar.css('left', 20)
  my_avatar.css('display', 'block')
  $('body').append my_avatar

# ユーザーのデータを表示する
actions['users'] = (data)->
  $('.users dl').empty()
  Object.keys(data.users).forEach ((key) ->
    val = @[key]
    if (my_uuid != val.uuid)
      icon = $('<dt>')
      opponent_avatar = $('#avatar-' + val.avatar).clone()
      opponent_avatar.attr('id', '')
      opponent_avatar.css('display', 'block')
      icon.append opponent_avatar

      color = $('<dd>')
      color.addClass(val.color)
      opponent_color = $('#color').clone()
      opponent_color.attr('id', '')
      color.append opponent_color

      color.append val.uuid

      $('.users dl').append icon
      $('.users dl').append color
    return
  ), data.users

# ゲームの開始, コントロール
actions['start'] = (data)->
  $('.attack-log').remove() # 初期化
  start_animation() # アニメーションをスタートさせる
  $('.timer').text 5 # カウントダウンタイマーで10を表示
  clearTimeout intervalID if intervalID
  intervalID = setInterval count_down, 1000 # 1秒ごとにcount_downを実行
  clearTimeout timeoutID if timeoutID #timeoutIDをクリア
  timeoutID = setTimeout game_finish, 5000 # 10秒後にgame_finishを実行

# waitingを表示
actions['waiting'] = (data)->
  console.log "waiting is called!"
  $('.waiting').show()

# dequeue joinメソッドを呼ぶ
actions['dequeue'] = (data, that)->
  console.log "dequeue is called!"
  that.perform 'join'

# attackが呼ばれる
actions['attack'] = (data)->
  console.log "attack is called!"
  attack_point = $('#ink-' + data.ink_type).clone()
  attack_point.attr('id', '')
  attack_point.css('position', 'absolute')
  attack_point.css('top', data.position.y - 250)
  attack_point.css('left', data.position.x - 250)
  attack_point.css('width', '500px')
  attack_point.css('height', '500px')
  attack_point.css('display', 'block')
  attack_point.addClass(data.color)
  attack_point.addClass('attack-log')
  $('body').append attack_point
  # 少し落ちるエフェクト
  attack_point.transition({ scale: 0.02 }, 200, 'snap')
    .transition({ background: 'none' }, 0)
    .transition({ scale: data.scale }, 200, 'ease')
    .transition({ y: 15 }, 1500, 'ease')
