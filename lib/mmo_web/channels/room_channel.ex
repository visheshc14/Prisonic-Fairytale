defmodule MmoWeb.RoomChannel do
  use Phoenix.Channel

  alias Mmo.World
  alias Mmo.Player

  def join("room:lobby", _message, socket) do
    {player,
     %World{
       players: players,
       background: background,
       foreground: foreground,
       items: items,
       leaf: leaf,
       enemies: enemies
     }} = GenServer.call(GameWorld, {:new_player})

    send(self(), {:new_player, player})

    socket =
      socket
      |> assign(:player_id, player.id)
      |> assign(:x, player.x)
      |> assign(:y, player.y)
      |> assign(:moving, false)

    {:ok,
     %{
       background: background,
       foreground: foreground,
       items: Map.values(items),
       leaf: leaf,
       player: player,
       players: Map.values(players),
       enemies: Map.values(enemies)
     }, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("key_up", data, socket) do
    broadcast!(socket, "update_world", data)
    {:noreply, socket}
  end

  def handle_in(
        "pointer_down",
        %{"x" => x, "y" => y},
        %{assigns: %{moving: true}} = socket
      ) do
    {:noreply, assign(socket, %{x: x, y: y})}
  end

  def handle_in("pointer_down", %{"x" => x, "y" => y}, socket) do
    schedule_work({:move_player})
    {:noreply, assign(socket, %{x: x, y: y})}
  end

  def handle_in(_call, _data, socket) do
    {:noreply, socket}
  end

  def handle_info({:new_player, player}, socket) do
    broadcast!(socket, "new_player", %{player: Map.from_struct(player)})
    {:noreply, socket}
  end

  def handle_info({:move_player}, %{assigns: %{player_id: player_id, x: x, y: y}} = socket) do
    case GenServer.call(
           GameWorld,
           {:move_player, %{player_id: player_id, x: x, y: y}}
         ) do
      {:static_object, {action, %Player{x: player_x, y: player_y} = player}} ->
        broadcast!(socket, action, %{
          player: player
        })

        {:noreply, assign(socket, %{moving: false, x: player_x, y: player_y})}

      {"player_attack", player, enemy} ->
        broadcast!(socket, "player_attack", %{
          player: player,
          enemy: enemy
        })

        {:noreply, assign(socket, :moving, false)}

      {"item", %Player{x: player_x, y: player_y} = player, item, respawned} ->
        is_moving =
          if (player_x != x or player_y != y) and not respawned do
            schedule_work({:move_player})
            true
          else
            false
          end

        broadcast!(socket, "item", %{
          player: player,
          item: item
        })

        {:noreply, assign(socket, :moving, is_moving)}

      {action, %Player{x: player_x, y: player_y} = player, respawned} ->
        is_moving =
          if (player_x != x or player_y != y) and not respawned do
            schedule_work({:move_player})
            true
          else
            false
          end

        broadcast!(socket, action, %{
          player: player
        })

        {:noreply, assign(socket, :moving, is_moving)}

      error ->
        IO.inspect(error, label: "Error")
        {:noreply, assign(socket, %{moving: false})}
    end
  end

  def terminate(reason, %{assigns: %{player_id: player_id}} = socket) do
    IO.inspect(%{reason: reason, player_id: player_id}, label: "Terminate")
    broadcast!(socket, "player_left", %{player_id: player_id})
    GenServer.cast(GameWorld, {:remove_player, player_id})
    {:error, reason}
  end

  defp schedule_work(event, time \\ 300) do
    # Interval in MS
    Process.send_after(self(), event, time)
  end
end
