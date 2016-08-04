alias Experimental.GenStage

defmodule Reactor.EventManager do
  use GenStage
  @name __MODULE__

  #Client API
  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: @name)
  end

  def fire_event({event_type, data}, timeout \\ 5000) do
    GenStage.call(@name, {:notify, {event_type, data}}, timeout)
  end

  #Server callbacks
  def init(:ok) do
    {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, from, {queue, demand}) do
    dispatch_events(:queue.in({from, event}, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, incoming_demand + demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
    {item, queue} = :queue.out(queue),
    {:value, {from, event}} <- item
    do
      GenStage.reply(from, :ok)
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
