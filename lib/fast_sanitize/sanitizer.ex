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
      scrub(subtree, scrubber)
      |> Fragment.to_html()
    else
      e ->
        {:error, e}
    end
  end

  def scrub(subtree, scrubber) when is_list(subtree) do
    Logger.debug("Pre-process: #{inspect(subtree)}")

    Enum.map(subtree, fn fragment ->
      case scrubber.scrub(fragment) do
        {_tag, _attrs, nil} = fragment ->
          Logger.debug("Post-process closure: #{inspect(fragment)}")
          fragment

        {tag, attrs, children} ->
          Logger.debug("Post-process tag: #{inspect({tag, attrs, children})}")
          {tag, attrs, scrub(children, scrubber)}

        subtree when is_list(subtree) ->
          Logger.debug("Post-process subtree: #{inspect(subtree)}")
          scrub(subtree, scrubber)

        other ->
          Logger.debug("Post-process other: #{inspect(other)}")
          other
      end
    end)
  end
end
