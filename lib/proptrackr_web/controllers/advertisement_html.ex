defmodule ProptrackrWeb.AdvertisementHTML do
  use ProptrackrWeb, :html


  embed_templates "advertisement_html/*"

  @doc """
  Renders a advertisement form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def advertisement_form(assigns)
end
