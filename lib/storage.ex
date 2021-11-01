defmodule Resources.StorageSettings do
  defstruct cap_values: nil
end


defmodule Resources.StorageServer do
  use GenServer
  alias Resources.StorageSettings

  def start(%StorageSettings{} = settings) do
    GenServer.start(__MODULE__, settings, name: __MODULE__)
  end

  @spec get_resource(any) :: any
  def get_resource(resource) do
    GenServer.call(__MODULE__, {:get, resource})
  end

  def increment_resource(resource, amount) do
    GenServer.cast(__MODULE__, {:inc, resource, amount})
  end

  @impl GenServer
  def init(settings) do
    {:ok, {1, settings, %{wood: 0, clay: 0, iron: 0}}}
  end

  @impl GenServer
  def handle_call({:get, resource_key}, _, state) do
    {_, _, counters} = state

    {
      :reply,
      Map.fetch!(counters, resource_key),
      state
    }
  end

  @impl GenServer
  def handle_cast({:inc, resource_key, amount}, {level, settings, counters}) do
    count = Map.fetch!(counters, resource_key)
    cap = Enum.at(settings.cap_values, level - 1)
    count = cond do
      count + amount > cap -> cap
      true -> count + amount
    end

    {
      :noreply,
      {level, settings, Map.put(counters, resource_key, count)}
    }
  end
end

