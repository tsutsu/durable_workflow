defmodule DurableWorkflow.DummyJob do
  require Logger

  def init({_opts, _plain_args}, _session), do: nil

  def handle_step(:start, state) do
    Logger.info "Executing dummy job"
    {:done, state}
  end
end
