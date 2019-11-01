defmodule FastSanitize.Sanitizer.Dummy do
  @moduledoc "A sanitizer policy which does nothing."

  def scrub(x), do: x
end
