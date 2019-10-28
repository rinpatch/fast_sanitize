defmodule FastSanitize.Fragment do
  import Plug.HTML, only: [html_escape: 1, html_escape_to_iodata: 1]

  def to_tree(bin) do
    with {:html, _, [{:head, _, _}, {:body, _, fragment}]} <-
           Myhtmlex.decode(bin, format: [:nil_self_closing, :comment_tuple3, :html_atoms]) do
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

  defp build_start_tag(tag, attrs, nil), do: ["<", to_string(tag), build_attr_chunks(attrs), "/>"]

  defp build_start_tag(tag, attrs, _children) when length(attrs) == 0,
    do: ["<", to_string(tag), ">"]

  defp build_start_tag(tag, attrs, _children),
    do: ["<", to_string(tag), build_attr_chunks(attrs), ">"]

  # empty tuple - fragment was clobbered, return nothing
  defp fragment_to_html(nil), do: ""

  defp fragment_to_html({}), do: ""

  # text node
  defp fragment_to_html(text) when is_binary(text), do: html_escape_to_iodata(text)

  # comment node
  defp fragment_to_html({:comment, _, text}), do: ["<!-- ", text, " -->"]

  # bare subtree
  defp fragment_to_html(subtree) when is_list(subtree) do
    {:ok, result} = subtree_to_html(subtree)
    result
  end

  # a node which can never accept children will have nil instead of a subtree
  defp fragment_to_html({tag, attrs, nil}), do: build_start_tag(tag, attrs, nil)

  # every other case, assume a subtree
  defp fragment_to_html({tag, attrs, subtree}) do
    with start_tag <- build_start_tag(tag, attrs, subtree),
         end_tag <- ["</", to_string(tag), ">"],
         subtree <- subtree_to_iodata(subtree) do
      [start_tag, subtree, end_tag]
    end
  end

  defp subtree_to_html([]), do: {:ok, ""}

  defp subtree_to_html(tree) do
    iodata = subtree_to_iodata(tree)
    rendered = :erlang.iolist_to_binary(iodata)
    {:ok, rendered}
  end

  defp subtree_to_iodata(tree),
    do: List.foldr(tree, [], fn node, iodata -> [fragment_to_html(node) | iodata] end)

  def to_html(tree), do: subtree_to_html(tree)
end
