defmodule Reactor.GameFSM do
  use Fsm, initial_state: :staging, initial_data: 0

  defstate staging do
    defevent start do
      next_state(:game_starting)
    end
  end

  defstate game_starting do
    defevent stage_round, data: count do
      next_state(:round_staging, count + 1)
    end
  end

  defstate round_staging do
    defevent start_round do
      next_state(:round_in_progress)
    end
  end

  defstate round_in_progress do
    defevent finish_round do
      next_state(:round_finished)
    end
  end

  defstate round_finished do
    defevent start_round, data: count do
      next_state(:round_staging, count + 1)
    end

    defevent finish_game do
      next_state(:game_over)
    end
  end
end
