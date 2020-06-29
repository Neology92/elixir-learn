defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel

  @impl true
  def join("comments:" <> topic_id, _params, socket) do
    topic =
      String.to_integer(topic_id)
      |> Discuss.Forums.get_topic_with_comments!()

    # comments_list = Discuss.Forums.list_comments()

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  @impl true
  def handle_in(_name, %{"content" => content}, socket) do
    IO.puts("=k==============================")
    IO.inspect(socket.assigns.topic)

    case Discuss.Forums.create_comment(%{content: content}, socket.assigns.topic) do
      {:ok, _comment} ->
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # def join("comments:lobby", payload, socket) do
  #   if authorized?(payload) do
  #     {:ok, socket}
  #   else
  #     {:error, %{reason: "unauthorized"}}
  #   end
  # end

  # # Channels can be used in a request/response fashion
  # # by sending replies to requests from the client
  # @impl true
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (comments:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end

  # # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end
