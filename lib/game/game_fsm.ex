defmodule Reactor.GameFSM do
  use Fsm, initial_state: :staging, initial_data: 0

  defstate staging do
    defevent start do
      next_state(:starting)
    end
  end

  defstate starting do
    defevent start_round, data: count do
      next_state(:in_round, count + 1)
    end
  end

  defstate in_round do
    defevent finish_round do
      next_state(:round_ended)
    end
  end

  defstate round_ended do
    defevent start_round, data: count do
      next_state(:round_started, count + 1)
    end

    defevent finish_game do
      next_state(:game_over)
    end
  end
end
