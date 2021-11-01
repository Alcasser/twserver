defmodule CountersServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def get_resource(resource) do
    GenServer.call(__MODULE__, {:get, resource})
  end

  def increment_resource(resource, amount) do
    GenServer.cast(__MODULE__, {:inc, resource, amount})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{wood: 0, clay: 0, iron: 0}}
  end

  @impl GenServer
  def handle_call({:get, resource_key}, _, counters) do
    {
      :reply,
      Map.fetch!(counters, resource_key),
      counters
    }
  end

  @impl GenServer
  def handle_cast({:inc, resource_key, amount}, counters) do
    count = Map.fetch!(counters, resource_key)
    {
      :noreply,
      Map.put(counters, resource_key, count + amount)
    }
  end
end

