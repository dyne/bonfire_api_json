defmodule Bonfire.API.JSON.Router do
  @moduledoc """
  Bonfire JSON API for temporary needs.  Might be removed in the future
  or obsoleted.
  """

  defmacro __using__(_) do
    quote do
      pipeline :api_json do
        plug :accepts, ["json"]
      end

      scope "/api/json", Bonfire.API.JSON do
        pipe_through(:api_json)

        post "/get-objects", Controller, :get_objects
        post "/track", Controller, :track
        post "/trace", Controller, :trace
      end
    end
  end
end
