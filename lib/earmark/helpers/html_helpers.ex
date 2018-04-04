defmodule Earmark.Helpers.HtmlHelpers do

  use Earmark.Types

  alias Earmark.Context

  import Earmark.Helpers.AttrParser
  
  @simple_tag ~r{^<(.*?)\s*>}

  @doc false

  @spec augment_tag_with_ial( Context.t, String.t, String.t, non_neg_integer ) :: maybe({Context.t, String.t})
  def augment_tag_with_ial(context, tag, ial, lnb) do 
    case Regex.run( @simple_tag, tag) do 
      nil -> nil
      _   -> add_attrs(context, tag, ial, [], lnb)
    end
    
  end


  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################


  @typep container_t :: Earmark.Message.container_type
  @spec add_attrs( container_t, String.t, maybe(String.t|map), list(tuple), non_neg_integer ) :: {container_t, String.t}
  def add_attrs(context, text, attrs_as_string_or_map, default_attrs, lnb )

  def add_attrs(context, text, nil, [], _lnb), do: {context, text}

  def add_attrs(context, text, nil, default, lnb), do: add_attrs(context, text, %{}, default, lnb)

  def add_attrs(context, text, attrs, default, lnb) when is_binary(attrs) do
    {context1, attrs} = parse_attrs( context, attrs, lnb )
    add_attrs(context1, text, attrs, default, lnb)
  end

  def add_attrs(context, text, attrs, default, _lnb) do
    {context, 
      default
      |> Enum.into(attrs)
      |> attrs_to_string()
      |> add_to(text)}
  end

  @spec attrs_to_string( map ) :: String.t
  defp attrs_to_string(attrs) do
    (for { name, value } <- attrs, do: ~s/#{name}="#{Enum.join(value, " ")}"/)
                                                  |> Enum.join(" ")
  end

  @spec add_to( String.t, String.t ) :: String.t
  defp add_to(attrs, text) do
    attrs = if attrs == "", do: "", else: " #{attrs}"
    String.replace(text, ~r{\s?/?>}, "#{attrs}\\0", global: false)
  end

end

# SPDX-License-Identifier: Apache-2.0
