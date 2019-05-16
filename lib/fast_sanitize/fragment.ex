defmodule FastSanitize.Fragment do
  require Logger

  def to_tree(bin) do
    with {:html, _, [{:head, _, _}, {:body, _, fragment}]} <-
           Myhtmlex.decode(bin, format: [:html_atoms, :nil_self_closing, :comment_tuple3]) do
      {:ok, fragment}
    else
      e -> {:error, e}
    end
  end

  defp build_start_tag(tag, attrs) when length(attrs) == 0, do: "<#{tag}>"

  defp build_start_tag(tag, attrs) do
    attr_chunks =
      Enum.map(attrs, fn {k, v} ->
        "#{k}=\"#{v}\""
      end)
      |> Enum.join(" ")

    "<#{tag} #{attr_chunks}>"
  end

  # empty tuple - fragment was clobbered, return nothing
  defp fragment_to_html({}), do: ""

  # text node
  defp fragment_to_html(text) when is_binary(text), do: text

  # comment node
  defp fragment_to_html({:comment, _, text}), do: "<!-- #{text} -->"

  # a node which can never accept children will have nil instead of a subtree
  defp fragment_to_html({tag, attrs, nil}), do: build_start_tag(tag, attrs)

  # every other case, assume a subtree
  defp fragment_to_html({tag, attrs, subtree}) do
    with start_tag <- build_start_tag(tag, attrs),
         end_tag <- "</#{tag}>",
         {:ok, subtree} <- subtree_to_html(subtree) do
      [start_tag, subtree, end_tag]
      |> Enum.join("")
    end
  end

  defp subtree_to_html([]), do: {:ok, ""}

  defp subtree_to_html(tree) do
    rendered =
      Enum.map(tree, &fragment_to_html/1)
      |> Enum.join("")

    {:ok, rendered}
  end

  def to_html(tree), do: subtree_to_html(tree)
end
