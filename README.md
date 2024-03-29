# poolboy_project
I developed this project intending to improve my knowledge by utilizing the Poolboy library for effective connection pooling. The main emphasis is on overseeing a pool of HTTP requests, enhancing the retrieval of HTML content, and subsequently parsing it using the Floki HTML parser

## Key words

- Web Scraping
- Data Extraction
- Concurrent Processing

## Local Setup

### Elixir

To run the project, you'll need to have Elixir installed. An easy way to install it is by using [asdf](https://asdf-vm.com/#/core-manage-asdf-vm). The file `.tool-versions` contains the version of Elixir used in this project and to install it you can run:

```bash
asdf install
```

### Dependencies

To install the dependencies, run:

```bash
mix deps.get
```

### Getting Starting

```bash
$ iex -S mix
iex(1)> Scraper.fetch_and_parse([
    ["github.com"]
])
```
### Tests

To run the tests, run:

```bash
mix test
```

