# test/scraper_test.exs
defmodule ScraperTest do
  use ExUnit.Case, async: false

  alias Adapters.Result, as: Result
  import ExUnit.CaptureLog

  import Mox

  test "fetch and parse success" do
    links = [
      "https://www.github.com"
    ]

    hrefs = [
      "https://www.github_href_1.com",
      "https://www.github_href_2.com",
      "https://www.github_href_3.com",
      "https://www.github_href_4.com"
    ]

    img_links = [
      "https://www.github_image_1.com/image.jpg",
      "https://www.github_image_2.com/image.png",
      "https://www.github_image_3.com/image.gif"
    ]

    html = generate_mock_html(hrefs, img_links)

    expect(HttpMock, :fetch, fn _url -> {:ok, html} end)

    assert capture_log(fn ->
             result = Scraper.fetch_and_parse(links)

             assert result == [
                      %Adapters.Result{
                        assets: [
                          "https://www.github_image_1.com/image.jpg",
                          "https://www.github_image_2.com/image.png",
                          "https://www.github_image_3.com/image.gif"
                        ],
                        errors: [],
                        links: [
                          "https://www.github_href_1.com",
                          "https://www.github_href_2.com",
                          "https://www.github_href_3.com",
                          "https://www.github_href_4.com"
                        ],
                        url: "https://www.github.com"
                      }
                    ]
           end) =~
             "\e[22m[info] parsing https://www.github.com...\n\e[0m\e[22m[info] body from https://www.github.com parsed!\n\e[0m"
  end

  Enum.each(
    [
      :timeout,
      :not_found,
      :bad_request
    ],
    fn status ->
      test "return error when status is #{status}" do
        capture_log(fn ->
          url = "http://example.com"

          # Stub the HttpPort.fetch function to simulate a timeout
          Mox.expect(HttpMock, :fetch, fn _url -> {:error, unquote(status)} end)

          result = Scraper.fetch_and_parse([url])
          assert result == [%Result{assets: [], url: url, errors: [{:error, unquote(status)}]}]
        end) =~
          "\e[31m[error] Error occurred while processing the request for URL http://example.com: {:error, #{unquote(status)}}\n\e[0m"
      end
    end
  )

  defp generate_mock_html(links, img_links) do
    (links ++ img_links)
    |> Enum.map_join(&generate_link_or_img_tag(&1))
    |> generate_html_document
  end

  defp generate_link_or_img_tag(url) do
    if String.contains?(url, "image") do
      generate_img_tag(url)
    else
      generate_link_tag(url)
    end
  end

  defp generate_link_tag(url) do
    ~s{<a href="#{url}">Link to #{url}</a>}
  end

  defp generate_img_tag(url) do
    ~s{<img src="#{url}" alt="Image from #{url}">}
  end

  defp generate_html_document(content) do
    ~s{
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mock HTML Document</title>
      </head>
      <body>
        #{content}
      </body>
      </html>
    }
  end
end
