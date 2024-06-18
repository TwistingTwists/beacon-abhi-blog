defmodule BeaconTagsField do
  use Phoenix.Component
  import BeaconWeb.CoreComponents
  import Ecto.Changeset

  @behaviour Beacon.Content.PageField

  @impl true
  def name, do: :tags

  @impl true
  def type, do: :string

  @impl true
  def default, do: "beacon,dev"

  @impl true
  def render(assigns) do
    ~H"""
    <.input type="text" label="Tags" field={@field} />
    """
  end

  @impl true
  def changeset(data, attrs, _metadata) do
    data
    |> cast(attrs, [:tags])
    |> validate_format(:tags, ~r/,/, message: "invalid format, expected ,")
  end

  def seed_dev() do
    dev_seeds = fn ->
      Beacon.Content.create_stylesheet!(%{
        site: "dev",
        name: "sample_stylesheet",
        content: "body {cursor: zoom-in;}"
      })

      layout =
        Beacon.Content.create_layout!(%{
          site: "dev",
          title: "dev",
          meta_tags: [
            %{"name" => "layout-meta-tag-one", "content" => "value"},
            %{"name" => "layout-meta-tag-two", "content" => "value"}
          ],
          resource_links: [
            %{"rel" => "stylesheet", "href" => "print.css", "media" => "print"},
            %{"rel" => "stylesheet", "href" => "alternative.css"}
          ],
          template: """
          <%= @inner_content %>
          """
        })

      Beacon.Content.publish_layout(layout)

      Beacon.Content.create_component!(%{
        site: "dev",
        name: "sample_component",
        body: """
        <li>
          <%= @val %>
        </li>
        """
      })

      Beacon.Content.create_snippet_helper!(%{
        site: "dev",
        name: "author_name",
        body: ~S"""
        author_id = get_in(assigns, ["page", "extra", "author_id"])
        "author_#{author_id}"
        """
      })

      metadata =
        Beacon.MediaLibrary.UploadMetadata.new(
          :dev,
          Path.join(:code.priv_dir(:beacon), "assets/dockyard-wide.jpeg"),
          name: "dockyard_1.png",
          size: 196_000,
          extra: %{"alt" => "logo"}
        )

      _img1 = Beacon.MediaLibrary.upload(metadata)

      metadata =
        Beacon.MediaLibrary.UploadMetadata.new(
          :dev,
          Path.join(:code.priv_dir(:beacon), "assets/dockyard-wide.jpeg"),
          name: "dockyard_2.png",
          size: 196_000,
          extra: %{"alt" => "alternate logo"}
        )

      _img2 = Beacon.MediaLibrary.upload(metadata)

      home_live_data = Beacon.Content.create_live_data!(%{site: "dev", path: "/"})

      Beacon.Content.create_assign_for_live_data(
        home_live_data,
        %{
          format: :elixir,
          key: "year",
          value: """
          Date.utc_today().year
          """
        }
      )

      Beacon.Content.create_assign_for_live_data(
        home_live_data,
        %{
          format: :elixir,
          key: "img1",
          value: """
          [img1] = Beacon.MediaLibrary.search(:dev, "dockyard_1")
          img1
          """
        }
      )

      page_home =
        Beacon.Content.create_page!(%{
          path: "/",
          site: "dev",
          title: "dev home",
          description: "page used for development",
          layout_id: layout.id,
          meta_tags: [
            %{"property" => "og:title", "content" => "title: {{ page.title | upcase }}"}
          ],
          raw_schema: [
            %{
              "@context": "https://schema.org",
              "@type": "BlogPosting",
              headline: "{{ page.description }}",
              author: %{
                "@type": "Person",
                name: "{% helper 'author_name' %}"
              }
            }
          ],
          extra: %{
            "author_id" => 1
          },
          template: """
          <main>
            <%!-- Home Page --%>

            <h1 class="text-violet-500">Dev</h1>
            <p class="text-sm">Page</p>

            <div>
              <p>Pages:</p>
              <ul>
                <li><.link patch="/dev/authors/1-author">Author (patch)</.link></li>
                <li><.link navigate="/dev/posts/2023/my-post">Post (navigate)</.link></li>
                <li><.link navigate="/dev/markdown">Markdown Page</.link></li>
              </ul>
            </div>

            <div>
              Sample component: <%= my_component("sample_component", val: 1) %>
            </div>

            <div>
              <BeaconWeb.Components.image_set asset={@beacon_live_data[:img1]} sources={["480w"]} width="200px" />
            </div>

            <div>
              <p>From data source:</p>
              <%= @beacon_live_data[:year] %>
            </div>

            <div>
              <p>From dynamic_helper:</p>
              <!-- %= dynamic_helper("upcase", %{name: "beacon"}) %> -->
            </div>

            <div>
              <p>RANDOM:<%= Enum.random(1..100) %></p>
            </div>
          </main>
          """,
          helpers: [
            %{
              name: "upcase",
              args: "%{name: name}",
              code: """
                String.upcase(name)
              """
            }
          ]
        })

      Beacon.Content.publish_page(page_home)

      page_author =
        Beacon.Content.create_page!(%{
          path: "/authors/:author_id",
          site: "dev",
          title: "dev author",
          layout_id: layout.id,
          template: """
          <main>
            <h1 class="text-violet-500">Authors</h1>

            <div>
              <p>Pages:</p>
              <ul>
                <li><.link navigate="/dev">Home (navigate)</.link></li>
                <li><.link navigate="/dev/posts/2023/my-post">Post (navigate)</.link></li>
              </ul>
            </div>

            <div>
              <p>path params:</p>
              <p><%= inspect @beacon_path_params %></p>
            </div>
          </main>
          """
        })

      Beacon.Content.publish_page(page_author)

      page_post =
        Beacon.Content.create_page!(%{
          path: "/posts/*slug",
          site: "dev",
          title: "dev post",
          layout_id: layout.id,
          template: """
          <main>
            <h1 class="text-violet-500">Post</h1>

            <div>
              <p>Pages:</p>
              <ul>
                <li><.link navigate="/dev">Home (navigate)</.link></li>
                <li><.link patch="/dev/authors/1-author">Author (patch)</.link></li>
              </ul>
            </div>

            <div>
              <p>path params:</p>
              <p><%= inspect @beacon_path_params %></p>
            </div>
          </main>
          """
        })

      Beacon.Content.publish_page(page_post)

      page_markdown =
        Beacon.Content.create_page!(%{
          path: "/markdown",
          site: "dev",
          title: "dev markdown",
          layout_id: layout.id,
          format: "markdown",
          template: """
          # My Markdown Page

          ## Intro

          Back to [Home](/dev)
          """
        })

      Beacon.Content.publish_page(page_markdown)
    end
  end
end
