defmodule FastSanitize.Fragment.Test do
  use ExUnit.Case

  describe "to_tree/1" do
    test "it works for simple fragments" do
      {:ok, [{:h1, [], ["test"]}]} = FastSanitize.Fragment.to_tree("<h1>test</h1>")
    end
  end

  describe "to_html/1" do
    test "it works for simple fragment trees" do
      tree = [{:h1, [], ["test"]}]

      {:ok, "<h1>test</h1>"} = FastSanitize.Fragment.to_html(tree)
    end

    test "it works for simple fragment trees with atypical tags" do
      tree = [{:br, [], nil}, {:hr, [], nil}]

      {:ok, "<br><hr>"} = FastSanitize.Fragment.to_html(tree)
    end

    test "it works for simple fragment trees with non-terminating tags" do
      tree = [
        {:link,
         [
           {"rel", "stylesheet"},
           {"type", "text/css"},
           {"href", "http://example.com/example.css"}
         ], nil}
      ]

      {:ok, "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://example.com/example.css\">"} =
        FastSanitize.Fragment.to_html(tree)
    end
  end
end
