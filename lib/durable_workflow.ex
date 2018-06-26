defmodule DurableWorkflow do
  def sessions_dir do
    Application.get_env(:durable_workflow, :session_dir, "sessions")
  end

  def run(session), do: DurableWorkflow.Engine.run(session)
end
