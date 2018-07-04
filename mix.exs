defmodule DurableWorkflow.MixProject do
  use Mix.Project

  def project, do: [
    app: :durable_workflow,
    version: "0.1.2",
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
    {:ex_doc, ">= 0.0.0", only: :dev}
  ]
end
