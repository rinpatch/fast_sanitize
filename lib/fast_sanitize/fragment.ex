defmodule FastSanitize.Fragment do
  import Plug.HTML, only: [html_escape: 1]

  def to_tree(bin) do
    with {:html, _, [{:head, _, _}, {:body, _, fragment}]} <-
           Myhtmlex.decode(bin, format: [:html_atoms, :nil_self_closing, :comment_tuple3]) do
      {:ok, fragment}
    else
      e -> {:error, e}
    end
  end

  defp build_attr_chunks(attrs) do
    Enum.map(attrs, fn {k, v} ->
      "#{html_escape(k)}=\"#{html_escape(v)}\""
    end)
    |> Enum.join(" ")
  end

  defp build_start_tag(tag, attrs, nil), do: "<#{tag} #{build_attr_chunks(attrs)}/>"
  defp build_start_tag(tag, attrs, _children) when length(attrs) == 0, do: "<#{tag}>"
  defp build_start_tag(tag, attrs, _children), do: "<#{tag} #{build_attr_chunks(attrs)}>"

  # empty tuple - fragment was clobbered, return nothing
  defp fragment_to_html({}), do: ""

  # text node
  defp fragment_to_html(text) when is_binary(text), do: html_escape(text)

  # comment node
  defp fragment_to_html({:comment, _, text}), do: "<!-- #{text} -->"

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
         end_tag <- "</#{tag}>",
         {:ok, subtree} <- subtree_to_html(subtree) do
      [start_tag, subtree, end_tag]
      |> Enum.join("")
    end
  end

  defp subtree_to_html([]), do: {:ok, ""}

  defp subtree_to_html(tree) do
    rendered =
      Enum.reject(tree, &is_nil/1)
      |> Enum.map(&fragment_to_html/1)
      |> Enum.join("")

    {:ok, rendered}
  end

  def to_html(tree), do: subtree_to_html(tree)
end
