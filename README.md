# DurableWorkflow

`DurableWorkflow` is a library for creating finite-state machines (FSMs)
with automatic file-based persistence.

## Usage

```elixir
# Create a new durable FSM
job = DurableWorkflow.Session.new({DurableWorkflow.DummyJob, "dummy"})

# Run the FSM
DurableWorkflow.run(job)

# if the FSM crashes, or your system crashes, just run it again,
# and it'll pick up where it left off
job = DurableWorkflow.Session.load_last("dummy")
DurableWorkflow.run(job)

# running a completed FSM is idempotent (it just issues a warning and does nothing)
DurableWorkflow.run(job)
```

As well as programmatic use, `DurableWorkflow` FSMs can also be managed from the CLI.
You can create a `Mix.Task` for each job type using the `DurableWorkflow.MixTask`
helper mix-in:

```elixir
defmodule Mix.Tasks.Dummy do
  use DurableWorkflow.MixTask,
    shortdoc: "Does nothing much"

  def job_name, do: "dummy"
  def job, do: DurableWorkflow.DummyJob
end
```

...and then use it:

```bash
$ mix dummy
[durable_workflow] creating session dummy-20180625175301
[dummy-20180625175301] Executing dummy job
```

You can also reload crashed/aborted sessions from the command line:

```bash
$ mix dummy --session dummy-20180625175301 # or --session last
[durable_workflow warn] session 'dummy-20180625175301' is already completed
```

## Installation

Add `durable_workflow` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:durable_workflow, "~> 0.1.1"}
  ]
end
```
