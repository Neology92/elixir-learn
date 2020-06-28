defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Forums
  alias Discuss.Forums.Topic

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    topics = Forums.list_topics()
    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Forums.change_topic(%Topic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"topic" => topic_params}) do
    user = conn.assigns.user

    case Forums.create_topic(topic_params, user) do
      {:ok, _topic} ->
        conn
        |> put_flash(:success, "Topic created successfully.")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Forums.get_topic!(id)
    render(conn, "show.html", topic: topic)
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Forums.get_topic!(topic_id)
    changeset = Forums.change_topic(topic)

    render(conn, "edit.html", changeset: changeset, topic: topic)
  end

  def update(conn, %{"id" => topic_id, "topic" => topic_paramas}) do
    topic = Forums.get_topic!(topic_id)

    case Forums.update_topic(topic, topic_paramas) do
      {:ok, _topic} ->
        conn
        |> put_flash(:success, "Topic updated successfully.")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, topic: topic)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Forums.get_topic!(id)
    {:ok, _topic} = Forums.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Discuss.Forums.get_topic!(topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot edit that")
      |> redirect(to: Routes.topic_path(conn, :index))
      |> halt()
    end
  end
end
