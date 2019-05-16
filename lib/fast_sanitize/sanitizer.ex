defmodule FastSanitize.Sanitizer do
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
  def scrub("", _), do: ""
  def scrub(nil, _), do: ""

  def scrub(doc, scrubber) do
    with {:ok, subtree} <- Fragment.to_tree(doc) do
      Enum.map(subtree, fn fragment ->
        scrubber.scrub(fragment)
      end)
      |> Fragment.to_html()
    else
      e ->
        {:error, e}
    end
  end
end
