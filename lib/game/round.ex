defmodule Reactor.Round do
  use GenServer
  @random_color_picker Application.get_env(:reactor, :random_color_picker)

  ##Client API

  def start_link(game_id, users) do
    GenServer.start_link(__MODULE__, [game_id, users])
  end

  ##Server Callbacks

  def init([game_id, users]) do
    users =
      users
      |> Enum.map(fn(user) -> {user, %{name: user, answer: nil, et: nil}} end)
      |> Enum.into(%{})

    state = %{
      game_id: game_id,
      users: users
    }

    Process.send_after(self, {:find_winner}, 2000)
    GenServer.cast(self, {:start_round})
    {:ok, state}
  end

  def handle_cast({:start_round}, state) do
    {colors, instruction} = @random_color_picker.get_colors

    state =
      state
      |> Map.put(:colors, colors)
      |> Map.put(:instruction, instruction)

    Reactor.EventManager.fire_event({:new_round, state})

    {:noreply, state}
  end

  def handle_cast({:submit_answer, %{answer: answer, user: user, et: et}}, state) do
    state =
      state
      |> put_in([:users, user, :answer], answer)
      |> put_in([:users, user, :et], et)

    {:noreply, state}
  end

  def handle_info({:find_winner}, %{game_id: game_id, users: users, instruction: instruction} = state) do
    {name, _winner} =
      users
      |> find_users_with_correct_answers(instruction)
      |> find_quickest_user

    Reactor.EventManager.fire_event({:winner, %{user: name, game_id: game_id}})
    GenServer.stop(self, :end_of_round)

    {:noreply, state}
  end

  defp find_users_with_correct_answers(users, instruction) do
    Enum.filter(users, fn({_name, user}) -> user.answer == instruction end)
  end

  defp find_quickest_user([]) do
    GenServer.stop(self, :end_of_round)
  end

  defp find_quickest_user(users) do
    Enum.min_by(users, fn({_name, user}) -> user.et end)
  end
end
