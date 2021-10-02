defmodule Mmo.Item.HealthPot do
  alias Mmo.Item.HealthPot

  @derive Jason.Encoder
  defstruct [
    :id,
    :x,
    :y,
    :status,
    name: "small_health_pot",
    display_name: "Small Health Position",
    modifier: 25,
    affect: :heal,
    description: "Heals you for 25 health"
  ]

  def new(opts \\ []) do
    uuid = Ecto.UUID.generate()
    updated_opts = [id: uuid] ++ opts
    struct(HealthPot, updated_opts)
  end

  def small() do
    new()
  end
end
