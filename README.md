# FastSanitize

A high performance HTML sanitization library built on [FastHTML][fh], our
rewrite of Myhtmlex.  It was created to improve HTML sanitization performance
in [Pleroma][pl], a high-performance, versatile federated social networking
platform.

   [fh]: https://git.pleroma.social/pleroma/myhtmlex
   [pl]: https://pleroma.social

## Features

* Meta-programming: build your own scrubbing policies with macros, mostly
  compatible with HtmlSanitizeEx.
* Performance: on average, 2-3 times faster than HtmlSanitizeEx with typical
  documents with considerably less memory usage.
* Uses the MyHTML parsing engine which parses HTML in the same way browsers
  do.
* Uses an efficient AST for scrubbing HTML nodes and Erlang iolists for
  efficient HTML generation.

## Installation

The package can be installed by adding `fast_sanitize` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fast_sanitize, "~> 0.1.0"}
  ]
end
```

Docs can be found at [https://hexdocs.pm/fast_sanitize](https://hexdocs.pm/fast_sanitize).
