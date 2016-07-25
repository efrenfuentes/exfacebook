defmodule Exfacebook.Http do
  require Poison
  require Logger

  alias HTTPoison.Response
  alias Exfacebook.Error

  @moduledoc """
  Http requests using `hackney` and decode response using `HTTPoison` to `JSON`.
  """

  @http_options Application.get_env(:exfacebook,
    :http_options,
    [recv_timeout: :infinity,
     timeout: 10000,
     hackney: [timeout: 10000, pool: false]]
  )

  @doc """
  Make get request and return JSON response as dictionary.
  """
  @spec get(String) :: {:ok, Map.t} | {:error, Error.t}
  def get(url) do
    HTTPoison.get(url, [], @http_options) |> handle_error
  end


  @spec post(String, Map.t) :: {:ok, Map.t} | {:error, Error.t}
  def post(url, data) do
    HTTPoison.post(url, {:form, data}, ["Content-Type": "application/x-www-form-urlencoded"], @http_options) |> handle_error
  end


  def handle_error(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, _value} = state -> state
          error -> {:error, %Error{message: inspect(error)}}
        end
      {:ok, %Response{status_code: status_code}} ->
        {:error, %Error{status_code: status_code, message: "not found resource"}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{message: inspect(reason)}}
      _ ->
        {:error, %Error{message: "0xDEADBEEF happened"}}
    end
  end
end
