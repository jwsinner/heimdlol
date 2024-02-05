defmodule Heimdlol.Api.ClientTest do
  use ExUnit.Case, async: true

  alias Heimdlol.Api.Client

  @moduletag :capture_log

  describe "Client tests" do
    setup do
      good_response =
        {:ok,
         %Tesla.Env{
           status: 200,
           body: """
             {
               "data": "good data"
             }
           """
         }}

      bad_response = {:ok, %Tesla.Env{status: 400, body: "Bad body"}}
      rate_limit_response = {:ok, %Tesla.Env{status: 429, headers: [{"retry-after", "5"}]}}

      {:ok,
       good_response: good_response,
       bad_response: bad_response,
       rate_limit_response: rate_limit_response}
    end

    test "handle_response returns ok tuple with 200 status", %{good_response: good_response} do
      assert {:ok, %{"data" => data}} = Client.handle_response(good_response)
      assert data == "good data"
    end

    test "handle_response returns error tuple with 400 status", %{bad_response: bad_response} do
      assert {:error, message} = Client.handle_response(bad_response)
      assert message == "400 error: \"Bad body\""
    end

    test "handle_response returns error tuple with 429 status", %{
      rate_limit_response: rate_limit_response
    } do
      assert {:error, %{retry_after: 5}} = Client.handle_response(rate_limit_response)
    end

    test "handle_response returns error tuple with unknown response body" do
      assert {:error, error} = Client.handle_response({:ok, %{bad: "response"}})
      assert String.starts_with?(error, "Unknown error")
    end
  end
end
