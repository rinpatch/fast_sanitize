defmodule FastSanitize do
  alias FastSanitize.Sanitizer

  @moduledoc """
  Fast HTML sanitization module.
  """

  @doc """
  Strip all tags from a given document fragment.

  ## Example

      iex> FastSanitize.strip_tags("<h1>hello world</h1>")
      {:ok, "hello world"}
  """
  def strip_tags(doc), do: Sanitizer.scrub(doc, FastSanitize.Sanitizer.StripTags)

  @doc """
  Strip tags from a given document fragment that are not basic HTML.

  ## Example

      iex> FastSanitize.basic_html("<h1>hello world</h1><script>alert('xss')</script>")
      {:ok, "<h1>hello world</h1>alert(&#39;xss&#39;)"}
  """
  def basic_html(doc), do: Sanitizer.scrub(doc, FastSanitize.Sanitizer.BasicHTML)
end
