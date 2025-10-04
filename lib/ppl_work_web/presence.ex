defmodule PplWorkWeb.Presence do
  @moduledoc """
  Provides presence tracking for users in spaces.

  Phoenix Presence allows you to track which users are currently
  connected to which spaces in real-time.
  """
  use Phoenix.Presence,
    otp_app: :ppl_work,
    pubsub_server: PplWork.PubSub
end
