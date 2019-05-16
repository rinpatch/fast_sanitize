defmodule FastSanitize.Sanitizer.StripTags do
  require FastSanitize.Sanitizer.Meta
  alias FastSanitize.Sanitizer.Meta

  Meta.strip_comments()
  Meta.strip_everything_not_covered()
end
