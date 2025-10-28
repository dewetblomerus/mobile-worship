defmodule MobileWorship.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MobileWorship.Accounts` context.
  """

  def user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    user_attrs =
      Enum.into(attrs, %{
        auth0_id: "auth0|test_#{unique_id}",
        email: "user#{unique_id}@example.com",
        email_verified: true,
        name: "Test User #{unique_id}"
      })

    case MobileWorship.Accounts.upsert_with_auth0(%{
           uid: user_attrs.auth0_id,
           info: %{
             email: user_attrs.email,
             name: user_attrs.name,
             image: Map.get(user_attrs, :picture)
           },
           extra: %{
             raw_info: %{
               user: %{"email_verified" => user_attrs.email_verified}
             }
           }
         }) do
      {:ok, user} -> user
      {:error, reason} -> raise "Failed to create user fixture: #{inspect(reason)}"
    end
  end
end
