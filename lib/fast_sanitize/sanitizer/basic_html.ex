defmodule FastSanitize.Sanitizer.BasicHTML do
  @moduledoc "The default sanitizer policy."

  require FastSanitize.Sanitizer.Meta
  alias FastSanitize.Sanitizer.Meta

  @valid_schemes ["http", "https", "mailto"]

  Meta.strip_comments()

  Meta.allow_tag_with_uri_attributes(:a, ["href"], @valid_schemes)
  Meta.allow_tag_with_these_attributes(:a, ["name", "title"])

  Meta.allow_tag_with_these_attributes(:b, [])
  Meta.allow_tag_with_these_attributes(:blockquote, [])
  Meta.allow_tag_with_these_attributes(:br, [])
  Meta.allow_tag_with_these_attributes(:code, [])
  Meta.allow_tag_with_these_attributes(:del, [])
  Meta.allow_tag_with_these_attributes(:em, [])
  Meta.allow_tag_with_these_attributes(:h1, [])
  Meta.allow_tag_with_these_attributes(:h2, [])
  Meta.allow_tag_with_these_attributes(:h3, [])
  Meta.allow_tag_with_these_attributes(:h4, [])
  Meta.allow_tag_with_these_attributes(:h5, [])
  Meta.allow_tag_with_these_attributes(:hr, [])
  Meta.allow_tag_with_these_attributes(:i, [])

  Meta.allow_tag_with_uri_attributes(:img, ["src"], @valid_schemes)

  Meta.allow_tag_with_these_attributes(:img, [
    "width",
    "height",
    "title",
    "alt"
  ])

  Meta.allow_tag_with_these_attributes(:li, [])
  Meta.allow_tag_with_these_attributes(:ol, [])
  Meta.allow_tag_with_these_attributes(:p, [])
  Meta.allow_tag_with_these_attributes(:pre, [])
  Meta.allow_tag_with_these_attributes(:span, [])
  Meta.allow_tag_with_these_attributes(:strong, [])
  Meta.allow_tag_with_these_attributes(:table, [])
  Meta.allow_tag_with_these_attributes(:tbody, [])
  Meta.allow_tag_with_these_attributes(:td, [])
  Meta.allow_tag_with_these_attributes(:th, [])
  Meta.allow_tag_with_these_attributes(:thead, [])
  Meta.allow_tag_with_these_attributes(:tr, [])
  Meta.allow_tag_with_these_attributes(:u, [])
  Meta.allow_tag_with_these_attributes(:ul, [])

  Meta.strip_everything_not_covered()
end
