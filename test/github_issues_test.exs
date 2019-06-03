defmodule GithubIssuesTest do
  use ExUnit.Case
  doctest Issues

  import Issues.GithubIssues, only: [fetch: 2]

  test "returns response from the url constructed based on user and project" do
    # assert elem(fetch("elixir-lang", "elixir"), 1) == :ok
    # assert parse_args(["--help", "whatever"])
  end

  # test "3 arguments returned in tuple if 3 were provided" do
  #   assert parse_args(["user", "project", "77"]) == {"user", "project", 77}
  # end
  #
  # test "3 arguments with default count returned in tuple if 2 were provided" do
  #   assert parse_args(["user", "project"]) == {"user", "project", 4}
  # end
end
