defmodule Issues.CLI do
  @default_count 4
  @default_format_spacing 20
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help. Otherwise it is a github user name, project name, and (optionally) the number of entries to format.Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  Note that CLI args are passed in argv, which is a one dimensional array of strings
  """

  def parse_args(argv) do
    # OptionParser.parse(["-h", "1"], switches: [help: :boolean], aliases: [h: :help])
    # => {[help: true], ["1"], []}
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1) # extract the element at index 1
    |> cleaned_up_args
  end

  def cleaned_up_args([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def cleaned_up_args([user, project]) do
    {user, project, @default_count}
  end

  def cleaned_up_args(_) do
    :help
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [count|#{@default_count}]
    """

    System.halt(0)
  end

  def process({user, project, count}) do
     Issues.GithubIssues.fetch(user, project)
     |> decode_response
     |> sort_into_descending_order
     |> last_in_ascending_order(count)
     |> print_table_with_columns(["number", "created_at", "title"])
  end

  def print_table_with_columns(list, header) do
    list_of_numbers = Enum.map(list, &(&1["number"]))
    print_formatted_header(list_of_numbers, header)
    Enum.map(list, &(extract_data_with_header(&1, header)))
    |> Enum.join("~n")
    |> :io.format
  end

  def print_formatted_header(list_of_numbers, header) do
    max_num = max_width_of(list_of_numbers)

    number_header = String.pad_trailing(" #", max_num + 1)
    created_at_header = String.pad_trailing(" created_at", @default_format_spacing)
    title_header = String.pad_trailing(" title", @default_format_spacing)

    number_border = String.duplicate("-", max_num)
    created_at_border = String.duplicate("-", @default_format_spacing)
    title_border = String.duplicate("-", @default_format_spacing)

    IO.puts(Enum.join([number_header, created_at_header, title_header], " |"))
    IO.puts(Enum.join([number_border, created_at_border, title_border], "-+-"))
  end

  def max_width_of(column) do
    Enum.max(column)
    |> to_string
    |> String.length
  end

  def extract_data_with_header(item, headers) do
    %{"number" => number, "created_at" => created_at, "title" => title} = item
    Enum.join([number, created_at, title], " | ")
  end

  def last_in_ascending_order(list, count) do
    Enum.take(list, count)
    |> Enum.reverse
  end

  def sort_into_descending_order(issues) do
    Enum.sort(issues, &(&1["created_at"] > &2["created_at"]))
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    IO.puts "Error fetching issues from Github: #{error["message"]}"
    System.halt(2)
  end

  # mix run -e 'Issues.CLI.run(["-h"])' => run this in console, mix will know to run it in the context of the app
  # mix run -e 'Issues.CLI.run(["elixix-lang", "elixir"])'
  # elixir package manager: hex
end
