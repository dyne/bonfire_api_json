defmodule Bonfire.API.JSONTest do
  use ExUnit.Case
  doctest Bonfire.API.JSON

  test "greets the world" do
    assert Bonfire.API.JSON.hello() == :world
  end
end
