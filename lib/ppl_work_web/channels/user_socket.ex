defmodule PplWorkWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "space:*", PplWorkWeb.SpaceChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    # For now, we'll accept all connections
    # In production, you'd want to verify authentication here
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
