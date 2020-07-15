defmodule FastSanitize.Fragment do
  @moduledoc "Processing of HTML fragment trees."

  import Plug.HTML, only: [html_escape_to_iodata: 1]

  def to_tree(bin) do
    with {:ok, fragment} <-
           :fast_html.decode_fragment(bin,
             format: [:nil_self_closing, :comment_tuple3, :html_atoms]
           ) do
      {:ok, fragment}
    else
      e ->
        {:error, e}
    end
  end

  defp build_attr_chunks([]), do: ""

  defp build_attr_chunks(attrs) do
    List.foldr(attrs, [], fn {k, v}, iodata ->
      [[" ", html_escape_to_iodata(k), "=\"", html_escape_to_iodata(v), "\""] | iodata]
    end)
  end

  defp build_self_closing_tag(tag, attrs),
    do: ["<", to_string(tag), build_attr_chunks(attrs), "/>"]

  defp build_start_tag(tag, []),
    do: ["<", to_string(tag), ">"]

  defp build_start_tag(tag, attrs),
    do: ["<", to_string(tag), build_attr_chunks(attrs), ">"]

  # text node
  defp fragment_to_html("" <> _ = text, _), do: html_escape_to_iodata(text)

  # empty tuple - fragment was clobbered, return nothing
  defp fragment_to_html(nil, _), do: ""

  defp fragment_to_html({}, _), do: ""

  # comment node
  defp fragment_to_html({:comment, _, text}, _), do: ["<!--", text, "-->"]

  # a node which can never accept children will have nil instead of a subtree
  defp fragment_to_html({tag, attrs, nil}, _), do: build_self_closing_tag(tag, attrs)

  # every other case, assume a subtree
  defp fragment_to_html({tag, attrs, subtree}, scrubber) do
    start_tag = build_start_tag(tag, attrs)
    subtree = subtree_to_iodata(subtree, scrubber)
    [start_tag, subtree, "</", to_string(tag), ">"]
  end

  # bare subtree
  defp fragment_to_html([], _), do: ""

  defp fragment_to_html([_head | _tail] = subtree, scrubber) do
    subtree_to_iodata(subtree, scrubber)
  end

  defp subtree_to_html([], _), do: {:ok, ""}

  defp subtree_to_html(tree, scrubber) do
    iodata = subtree_to_iodata(tree, scrubber)
    rendered = :erlang.iolist_to_binary(iodata)
    {:ok, rendered}
  end

  defp subtree_to_iodata(tree, scrubber) do
    List.foldr(tree, [], fn node, iodata ->
      [fragment_to_html(scrubber.scrub(node), scrubber) | iodata]
    end)
  end

  def to_html(tree, scrubber \\ FastSanitize.Sanitizer.Dummy),
    do: subtree_to_html(tree, scrubber)
end
