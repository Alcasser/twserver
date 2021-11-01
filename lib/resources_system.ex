defmodule ResourceSettings do
  defstruct name: nil, gen_interval: nil, gen_values: nil
end

defmodule ResourcesSystem do
  @gen_values [
    10,
    20,
    30
  ]
  @gen_interval 10

  def init do
    CountersServer.start # Can return :already_started
    ResourceWorker.start_link(%ResourceSettings{
      name: :wood,
      gen_interval: @gen_interval,
      gen_values: @gen_values
    })
    ResourceWorker.start_link(%ResourceSettings{
      name: :clay,
      gen_interval: @gen_interval,
      gen_values: @gen_values
    })
    ResourceWorker.start_link(%ResourceSettings{
      name: :iron,
      gen_interval: @gen_interval,
      gen_values: @gen_values
    })
  end
end

defmodule ResourceWorker do
  use GenServer

  def start_link(%ResourceSettings{} = settings) do
    GenServer.start_link(__MODULE__, settings)
  end

  @impl GenServer
  def init(settings) do
    :timer.send_interval(settings.gen_interval * 1000, :next)

    {:ok, {1, settings}}
  end

  @impl GenServer
  def handle_info(:next, {level, settings}) do
    inc = Enum.at(settings.gen_values, level - 1)
    CountersServer.increment_resource(settings.name, inc)

    {:noreply, {level, settings}}
  end
end
