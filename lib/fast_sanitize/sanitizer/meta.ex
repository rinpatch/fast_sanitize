# Based on HtmlSanitizeEx.Scrubber.Meta
# Copyright (c) 2015-2019 René Föhring (@rrrene)

defmodule FastSanitize.Sanitizer.Meta do
  @moduledoc """
  This module contains some meta-programming magic to define your own rules
  for scrubbers.

  The StripTags scrubber is a good starting point:

      defmodule FastSanitize.Sanitizer.StripTags do
        require FastSanitize.Sanitizer.Meta
        alias FastSanitize.Sanitizer.Meta

        Meta.strip_comments

        Meta.strip_everything_not_covered
      end

  You can use the `allow_tag_with_uri_attributes/3` and
  `allow_tag_with_these_attributes/2` macros to define what is allowed:

      defmodule FastSanitize.Sanitizer.StripTags do
        require FastSanitize.Sanitizer.Meta
        alias FastSanitize.Sanitizer.Meta

        Meta.strip_comments

        Meta.allow_tag_with_uri_attributes   "img", ["src"], ["http", "https"]
        Meta.allow_tag_with_these_attributes "img", ["width", "height"]

        Meta.strip_everything_not_covered
      end

  You can stack these if convenient:

      Meta.allow_tag_with_uri_attributes   "img", ["src"], ["http", "https"]
      Meta.allow_tag_with_these_attributes "img", ["width", "height"]
      Meta.allow_tag_with_these_attributes "img", ["title", "alt"]

  """

  @doc """
  Allow these tags and use the regular `scrub_attribute/2` function to scrub
  the attributes.
  """
  defmacro allow_tags_and_scrub_their_attributes(list) do
    Enum.map(list, fn tag_name ->
      allow_this_tag_and_scrub_its_attributes(tag_name)
    end)
  end

  @doc """
  Allow the given +list+ of attributes for the specified +tag+.

      Meta.allow_tag_with_these_attributes "a", ["name", "title"]

      Meta.allow_tag_with_these_attributes "img", ["title", "alt"]
  """
  defmacro allow_tag_with_these_attributes(tag_name, list \\ []) do
    list
    |> Enum.map(fn attr_name ->
      allow_this_tag_with_this_attribute(tag_name, attr_name)
    end)
    |> Enum.concat([allow_this_tag_and_scrub_its_attributes(tag_name)])
  end

  @doc """
  Allow the given list of +values+ for the given +attribute+ on the
  specified +tag+.

      Meta.allow_tag_with_this_attribute_values "a", "target", ["_blank"]
  """
  defmacro allow_tag_with_this_attribute_values(tag_name, attribute, values) do
    quote do
      def scrub_attribute(unquote(tag_name), {unquote(attribute), value})
          when value in unquote(values) do
        {unquote(attribute), value}
      end
    end
  end

  @doc """
  Allow the given +list+ of attributes to contain URI information for the
  specified +tag+.

      # Only allow SSL-enabled and mailto links
      Meta.allow_tag_with_uri_attributes "a", ["href"], ["https", "mailto"]

      # Only allow none-SSL images
      Meta.allow_tag_with_uri_attributes "img", ["src"], ["http"]
  """
  defmacro allow_tag_with_uri_attributes(tag, list, valid_schemes) do
    list
    |> Enum.map(fn name ->
      allow_tag_with_uri_attribute(tag, name, valid_schemes)
    end)
  end

  @doc """

  """
  defmacro allow_tags_with_style_attributes(list) do
    list
    |> Enum.map(fn tag_name -> allow_this_tag_with_style_attribute(tag_name) end)
  end

  @doc """
  Strips all comments.
  """
  defmacro strip_comments do
    quote do
      def scrub({:comment, _, _}), do: nil
    end
  end

  @doc """
  Ensures any tags/attributes not explicitly whitelisted until this
  statement are stripped.
  """
  defmacro strip_everything_not_covered do
    quote do
      # If we haven't covered the attribute until here, we just scrap it.
      def scrub_attribute(_tag, _attribute), do: nil

      # If we haven't covered the attribute until here, we just scrap it.
      def scrub({_tag, _attributes, children}), do: children

      # Text is left alone
      def scrub("" <> _ = text), do: text
    end
  end

  @doc """
  Ensures any tags/attributes that are explicitly disallowed have
  their children dropped.
  """
  defmacro strip_children_of(tag_name) do
    quote do
      def scrub({unquote(tag_name), _attributes, _children}), do: nil
    end
  end

  defp allow_this_tag_and_scrub_its_attributes(tag_name) do
    quote do
      def scrub({unquote(tag_name), attributes, children}) do
        {unquote(tag_name), scrub_attributes(unquote(tag_name), attributes), children}
      end

      defp scrub_attributes(unquote(tag_name), attributes) do
        attributes
        |> Enum.map(fn attr ->
          scrub_attribute(unquote(tag_name), attr)
        end)
        |> Enum.reject(&is_nil(&1))
      end
    end
  end

  defp allow_this_tag_with_this_attribute(tag_name, attr_name) do
    quote do
      def scrub_attribute(unquote(tag_name), {unquote(attr_name), value}) do
        {unquote(attr_name), value}
      end
    end
  end

  defp allow_this_tag_with_style_attribute(tag_name) do
    quote do
      def scrub_attribute(unquote(tag_name), {"style", value}) do
        {"style", scrub_css(value)}
      end
    end
  end

  defp allow_tag_with_uri_attribute(tag_name, attr_name, valid_schemes) do
    quote do
      def scrub_attribute(unquote(tag_name), {unquote(attr_name), "&" <> value}) do
        nil
      end

      def scrub_attribute(unquote(tag_name), {unquote(attr_name), uri} = attr) do
        uri = URI.parse(uri)
        if uri.scheme == nil or uri.scheme in unquote(valid_schemes), do: attr
      end
    end
  end
end
