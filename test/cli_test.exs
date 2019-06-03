defmodule CliTest do
  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [parse_args: 1, sort_into_descending_order: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "whatever"]) == :help
    assert parse_args(["--help", "whatever"]) == :help
  end

  test "3 arguments returned in tuple if 3 were provided" do
    assert parse_args(["user", "project", "77"]) == {"user", "project", 77}
  end

  test "3 arguments with default count returned in tuple if 2 were provided" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "sort issues by descending created_at" do
    data = [
      %{"created_at" => 1, "other_data" => "abc"},
      %{"created_at" => 2, "other_data" => "xyz"}
    ]

    result = sort_into_descending_order(data)

    assert Enum.map(result, &(&1["other_data"])) == ["xyz", "abc"]
  end
end
