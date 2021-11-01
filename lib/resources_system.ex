defmodule Resources.ResourceSettings do
  defstruct name: nil, gen_interval: nil, gen_values: nil
end

defmodule Resources.System do
  alias Resources.Worker
  alias Resources.ResourceSettings
  alias Resources.StorageServer
  alias Resources.StorageSettings

  @wood_settings %ResourceSettings{
    name: :wood,
    gen_interval: 10,
    gen_values: [10, 20, 30]
  }
  @clay_settings %ResourceSettings{
    name: :clay,
    gen_interval: 10,
    gen_values: [10, 20, 30]
  }
  @iron_settings %ResourceSettings{
    name: :iron,
    gen_interval: 10,
    gen_values: [10, 20, 30]
  }
  @storage_settings %StorageSettings {
    cap_values: [50, 100, 150]
  }

  def init do
    StorageServer.start(@storage_settings) # Can return :already_started
    Worker.start_link(@wood_settings)
    Worker.start_link(@clay_settings)
    Worker.start_link(@iron_settings)
  end
end

defmodule Resources.Worker do
  use GenServer
  alias Resources.ResourceSettings
  alias Resources.StorageServer

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
    StorageServer.increment_resource(settings.name, inc)

    {:noreply, {level, settings}}
  end
end
