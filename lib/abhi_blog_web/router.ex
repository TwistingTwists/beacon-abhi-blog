defmodule AbhiBlogWeb.Router do
  use AbhiBlogWeb, :router
  use Beacon.Router
  # <- add this line
  use Beacon.LiveAdmin.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AbhiBlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # <- add this line
    plug Beacon.LiveAdmin.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # add the following scope before any beacon_site
  # scope "/admin" do
  #   pipe_through :browser
  #   beacon_live_admin "/"
  # end

  #   scope "/", AbhiBlogWeb do
  #     pipe_through :browser

  #     # get "/", PageController, :home
  #     beacon_site "/", site: :dev
  #   end

  scope "/admin" do
    pipe_through :browser
    beacon_live_admin "/"
  end

  scope "/" do
    pipe_through :browser
    beacon_site "/", site: :dev
    beacon_site "/site", site: :my_site
    beacon_site "/my_test_website", site: :my_test_website
  end

  # Other scopes may use custom stacks.
  # scope "/api", AbhiBlogWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:abhi_blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AbhiBlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
