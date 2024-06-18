defmodule AbhiBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AbhiBlogWeb.Telemetry,
      AbhiBlog.Repo,
      {DNSCluster, query: Application.get_env(:abhi_blog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AbhiBlog.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AbhiBlog.Finch},
      # Start a worker by calling: AbhiBlog.Worker.start_link(arg)
      # {AbhiBlog.Worker, arg},
      # Start to serve requests, typically the last entry
      {Beacon,
       sites: [
          dev_site(),
        #  [site: :dev, endpoint: AbhiBlog.Endpoint, skip_boot?: true]
       ]},
      AbhiBlogWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AbhiBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

    defp dev_site() do

   [
    site: :dev,
    endpoint: AbhiBlog.Endpoint,
    skip_boot?: true,
    extra_page_fields: [BeaconTagsField],
    lifecycle: [upload_asset: [thumbnail: &Beacon.Lifecycle.Asset.thumbnail/2, _480w: &Beacon.Lifecycle.Asset.variant_480w/2]],
    default_meta_tags: [
      %{"name" => "default", "content" => "dev"}
    ]
  ]
    end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AbhiBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
