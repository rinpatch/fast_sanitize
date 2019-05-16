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
end
