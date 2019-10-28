defmodule FastSanitize.Sanitizer do
  require Logger

  alias FastSanitize.Fragment

  @moduledoc """
  Defines the contract that Sanitizer modules must follow.
  """

  @doc """
  Scrubs a document node.
  """
  @callback scrub({atom(), list(), list()}) :: tuple()

  @doc """
  Scrubs an unknown node.
  """
  @callback scrub({binary(), list(), list()}) :: tuple()

  @doc """
  Scrubs a text node.
  """
  @callback scrub(binary()) :: binary()

  # fallbacks
  def scrub("", _), do: {:ok, ""}
  def scrub(nil, _), do: {:ok, ""}

  def scrub(doc, scrubber) when is_binary(doc) do
    with wrapped_doc <- "<body>" <> doc <> "</body>",
         {:ok, subtree} <- Fragment.to_tree(wrapped_doc) do
      Fragment.to_html(subtree, scrubber)
    else
      e ->
        {:error, e}
    end
  end
end
