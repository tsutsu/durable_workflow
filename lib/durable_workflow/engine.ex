defmodule DurableWorkflow.Engine do
  require Logger
  alias DurableWorkflow.Session

  def run(%Session{done: true} = session) do
    session_name = Session.name(session)
    Logger.warn "session '#{session_name}' is already completed"

    :done
  end

  def run(%Session{restored: restored?} = session) do
    Logger.debug fn ->
      session_name = Session.name(session)

      verb = case restored? do
        true -> "restoring"
        false -> "creating"
      end

      IO.ANSI.format([verb, " session ", :blue, session_name])
    end

    run_loop(session)
  end

  defp run_loop(%Session{job: job_module, step: step, state: state} = session) do
    case job_module.handle_step(step, state) do
      {:transition, next_step, new_state} ->
        session1 = Session.transaction session, fn sess ->
          sess
          |> Session.put_state(new_state)
          |> Session.put_step(next_step)
        end

        run_loop(session1)

      {:done, new_state} ->
        Session.transaction session, fn sess ->
          sess
          |> Session.put_state(new_state)
          |> Session.finish()
        end

        :done
    end
  end
end
