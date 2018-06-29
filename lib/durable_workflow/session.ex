defmodule DurableWorkflow.Session do
  defstruct [
    path: nil,
    job: nil,
    step: :start,
    done: false,
    restored: false,
    job_opts: %{},
    began_at: nil,
    state: nil,
    in_tx: false
  ]

  def new({job, job_name}, job_opts) do
    began_at = DateTime.utc_now()

    session_name = [job_name, Timex.format!(began_at, "{ASN1:GeneralizedTime}")] |> Enum.join("-")

    session_path = Path.join(DurableWorkflow.sessions_dir(), session_name)

    if File.exists?(session_path) do
      raise RuntimeError, "session already exists at '#{session_path}'!"
    end

    File.mkdir_p!(session_path)

    session = %__MODULE__{
      path: session_path,
      job: job,
      began_at: began_at
    }

    session
    |> Map.put(:state, job.init(job_opts, session))
    |> persist!()
  end

  def load(session_name, job_opts) do
    session_path = Path.join(DurableWorkflow.sessions_dir(), session_name)

    unless File.exists?(session_path) do
      raise ArgumentError, "session '#{session_name}' does not exist"
    end

    session = restore!(session_path)

    if session.done do
      session
    else
      session
      |> Map.put(:state, session.job.init(job_opts, session))
      |> persist!()
    end
  end

  def load_last(job_name, job_opts) do
    newest_job_of_type = [DurableWorkflow.sessions_dir(), "#{job_name}-*"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(&Path.basename/1)
    |> Enum.sort(&(&1 <= &2))
    |> List.first

    case newest_job_of_type do
      session_name when is_binary(session_name) ->
        load(session_name, job_opts)

      nil ->
        raise RuntimeError, "no sessions of type '#{job_name}' found"
    end
  end

  def reload(%__MODULE__{path: session_path}) when is_binary(session_path) do
    session = restore!(session_path)

    if session.done do
      session
    else
      session
      |> Map.put(:state, session.job.init(nil, session))
      |> persist!()
    end
  end


  def transaction(%__MODULE__{} = session, fun) when is_function(fun, 1) do
    session = %{session | in_tx: true}
    session = fun.(session)
    session = %{session | in_tx: false}

    persist!(session)
  end

  def put_step(%__MODULE__{in_tx: true} = session, new_step), do:
    Map.put(session, :step, new_step)

  def put_state(%__MODULE__{in_tx: true} = session, new_state), do:
    Map.put(session, :state, new_state)

  def finish(%__MODULE__{in_tx: true} = session), do:
    struct(session, step: nil, done: true)

  def name(%__MODULE__{path: path}) when is_binary(path), do:
    Path.basename(path)


  defp restore!(session_path) do
    File.read!(session_file_path(session_path))
    |> :erlang.binary_to_term
    |> Map.put(:path, session_path)
    |> Map.put(:restored, true)
  end

  defp persist!(%__MODULE__{in_tx: false, path: session_path} = session_data) do
    cleaned_session_data = Map.put(session_data, :path, nil)

    File.write!(
      session_file_path(session_path),
      :erlang.term_to_binary(cleaned_session_data)
    )

    session_data
  end

  defp session_file_path(session_path) do
    Path.join(session_path, "session.etf")
  end
end
