defmodule PhoenixPayWeb do
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def html do
    quote do
      use Phoenix.HTML
      import PhoenixPayWeb.Gettext
      import Phoenix.Component
      import Phoenix.HTML.Form
      import PhoenixPayWeb.CoreComponents
    end
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: PhoenixPayWeb
      import Plug.Conn
      import PhoenixPayWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {PhoenixPayWeb.Layouts, :app}

      import PhoenixPayWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import PhoenixPayWeb.Gettext

      unquote(verified_routes())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import PhoenixPayWeb.Gettext
    end
  end

  defp verified_routes do
    quote do
      # no routes for now
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
