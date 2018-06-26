defmodule DurableWorkflow.MixProject do
  use Mix.Project

  def project, do: [
    app: :durable_workflow,
    version: "0.1.0",
    elixir: "~> 1.6",
    description: description(),
    package: package(),
    deps: deps()
  ]

  defp description, do:
  """
  A library for creating finite-state machines with automatic file-based persistence.
  """

  defp package, do: [
    name: :durable_workflow,
    files: ["config", "lib", "mix.exs", "LICENSE"],
    maintainers: ["Levi Aul"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/tsutsu/durable_workflow"}
  ]

  def application, do: [
    extra_applications: [:logger]
  ]

  defp deps, do: [
    {:timex, "~> 3.3"},
    {:ex_doc, ">= 0.0.0", only: :dev}
  ]
end
