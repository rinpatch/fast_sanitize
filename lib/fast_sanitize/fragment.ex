defmodule FastSanitize.Fragment do
  import Plug.HTML, only: [html_escape_to_iodata: 1]

  # Generate a lookup table from atoms to binaries
  @known_tags [
    :a,
    :article,
    :aside,
    :body,
    :br,
    :details,
    :div,
    :h1,
    :h2,
    :h3,
    :h4,
    :h5,
    :h6,
    :head,
    :header,
    :hgroup,
    :hr,
    :html,
    :footer,
    :nav,
    :p,
    :section,
    :span,
    :summary,
    :base,
    :basefont,
    :link,
    :meta,
    :style,
    :title,
    :button,
    :datalist,
    :fieldset,
    :form,
    :input,
    :keygen,
    :label,
    :legend,
    :meter,
    :optgroup,
    :option,
    :select,
    :textarea,
    :abbr,
    :acronym,
    :address,
    :b,
    :bdi,
    :bdo,
    :big,
    :blockquote,
    :center,
    :cite,
    :code,
    :del,
    :dfn,
    :em,
    :font,
    :i,
    :mark,
    :output,
    :pre,
    :progress,
    :q,
    :rp,
    :rt,
    :ruby,
    :s,
    :samp,
    :small,
    :strike,
    :strong,
    :sub,
    :sup,
    :tt,
    :u,
    :var,
    :wbr,
    :dd,
    :dir,
    :dl,
    :dt,
    :li,
    :ol,
    :menu,
    :ul,
    :caption,
    :col,
    :colgroup,
    :table,
    :tbody,
    :td,
    :tfoot,
    :thead,
    :th,
    :tr,
    :noscript,
    :script,
    :applet,
    :area,
    :audio,
    :canvas,
    :embed,
    :figcaption,
    :figure,
    :frame,
    :frameset,
    :iframe,
    :img,
    :map,
    :noframes,
    :object,
    :param,
    :source,
    :time,
    :video
  ]

  for tag <- @known_tags do
    string_tag = to_string(tag)

    def tag_to_string(unquote(tag)), do: unquote(string_tag)
  end

  def tag_to_string("" <> binary), do: binary

  def tag_to_string(atom), do: to_string(atom)

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

  defp build_start_tag(tag, attrs, nil),
    do: ["<", tag_to_string(tag), build_attr_chunks(attrs), "/>"]

  defp build_start_tag(tag, attrs, _children) when length(attrs) == 0,
    do: ["<", tag_to_string(tag), ">"]

  defp build_start_tag(tag, attrs, _children),
    do: ["<", tag_to_string(tag), build_attr_chunks(attrs), ">"]

  # empty tuple - fragment was clobbered, return nothing
  defp fragment_to_html(nil, _), do: ""

  defp fragment_to_html({}, _), do: ""

  # text node
  defp fragment_to_html(text, _) when is_binary(text), do: html_escape_to_iodata(text)

  # comment node
  defp fragment_to_html({:comment, _, text}, _), do: ["<!-- ", text, " -->"]

  # bare subtree
  defp fragment_to_html(subtree, scrubber) when is_list(subtree) do
    subtree_to_iodata(subtree, scrubber)
  end

  # a node which can never accept children will have nil instead of a subtree
  defp fragment_to_html({tag, attrs, nil}, _), do: build_start_tag(tag, attrs, nil)

  # every other case, assume a subtree
  defp fragment_to_html({tag, attrs, subtree}, scrubber) do
    with start_tag <- build_start_tag(tag, attrs, subtree),
         end_tag <- ["</", tag_to_string(tag), ">"],
         subtree <- subtree_to_iodata(subtree, scrubber) do
      [start_tag, subtree, end_tag]
    end
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
