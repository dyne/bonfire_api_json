defmodule Bonfire.API.JSON.MixProject do
  use Mix.Project

  def project() do
    [
      app: :bonfire_api_json,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  def application() do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps() do
    [
      {:bonfire_data_identity, ">= 0.0.0"},
      {:bonfire_valueflows, ">= 0.0.0"},
      {:bonfire_common, ">= 0.0.0"},
    ]
  end
end
