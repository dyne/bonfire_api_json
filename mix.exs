defmodule Bonfire.API.JSON.MixProject do
  use Mix.Project

  def project() do
    [
      app: :bonfire_api_json,
      version: "0.1.0",
      elixir: "~> 1.10",
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
      {:bonfire_data_identity, git: "https://github.com/bonfire-networks/bonfire_data_identity.git", branch: "main"},
      {:bonfire_valueflows, git: "https://github.com/dyne/bonfire_valueflows.git", branch: "bf"},
      {:bonfire_common, git: "https://github.com/bonfire-networks/bonfire_common.git", branch: "main"},
    ]
  end
end
