# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class BattleChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
  end

  def unsubscribed
    user = User.new(uuid)
    user.leave

    carry_up_uuid = User.carry_up
    ActionCable.server.broadcast "player_#{carry_up_uuid}", { action: "dequeue" }
  end

  def join(data)
    user = User.new(uuid)
    return waiting unless user.can_join?

    ActionCable.server.broadcast "player_#{uuid}", data.merge(user.params)
    ActionCable.server.broadcast "player_#{uuid}", { action: "users", users: User.all }
    ActionCable.server.broadcast "battle_channel", { action: "users", users: User.all }

    stream_from "battle_channel"

    start
    # start if User.all.size > (Battle.max_user - 1)
  end

  def start
    ActionCable.server.broadcast "battle_channel", { action: "start" }
  end

  def attack(data)
    ActionCable.server.broadcast "battle_channel", data.merge({ scale: [0.4, 0.45, 0.5, 0.55, 0.6].sample })
  end

  def waiting
    User.new(uuid).waiting
    ActionCable.server.broadcast "player_#{uuid}", { action: "waiting" }
  end
end
