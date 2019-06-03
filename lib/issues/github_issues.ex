defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issue_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issue_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {
      status_code |> check_for_error,
      body        |> Poison.Parser.parse!(%{})
    }
  end

  def check_for_error(200), do: :ok
  def check_for_error(_), do: :error
end
