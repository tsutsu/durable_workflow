defmodule DurableWorkflow.MixTask do
  defmacro __using__(opts) do
    shortdoc = Keyword.get(opts, :shortdoc)

    quote location: :keep do
      use Mix.Task

      def job_name, do: "job"
      def job, do: DurableWorkflow.DummyJob
      def switches, do: []

      defoverridable [job_name: 0, job: 0, switches: 0]

      @shortdoc unquote(shortdoc)
      def run(argv) do
        {opts, plain_args, []} = OptionParser.parse(argv, switches: ([session: :string] ++ switches()))

        DurableWorkflow.MixTask.bootstrap_application!()

        {session_name_opt, opts} = Keyword.pop(opts, :session)

        job_opts = {opts, plain_args}

        session = case session_name_opt do
          "" ->
            raise ArgumentError, "session name cannot be empty"

          "last" ->
            DurableWorkflow.Session.load_last(job_name(), job_opts)

          session_name when is_binary(session_name) ->
            DurableWorkflow.Session.load(session_name, job_opts)

          nil ->
            DurableWorkflow.Session.new({job(), job_name()}, job_opts)
        end

        DurableWorkflow.run(session)
      end
    end
  end

  def bootstrap_application! do
    Mix.Task.run("run")

    if Code.ensure_loaded?(PrettyConsole) do
      :erlang.apply(PrettyConsole, :install!, [])
    end
  end
end
