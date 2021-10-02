defmodule Mmo.Item.PsycoMedic do
  alias Mmo.Item.PsycoMedic
  alias Mmo.Player

  @derive Jason.Encoder
  defstruct [
    :id,
    :x,
    :y,
    :status,
    name: "psycho_medic",
    display_name: "Psycho Medic",
    modifier: 75,
    affect: :heal,
    description: "Could heal you, could hurt you, or could buff your attack"
  ]

  def new(opts \\ []) do
    uuid = Ecto.UUID.generate()
    affect = Enum.random([:heal, :heal, :heal, :hurt, :hurt, :hurt, :buff_attack])
    {x, y} = Enum.random([{48, 70}, {60, 39}, {93, 33}, {61, 23}])
    updated_opts = [id: uuid, affect: affect, x: x, y: y] ++ opts
    struct(PsycoMedic, updated_opts)
  end

  def small() do
    new()
  end

  def apply_effect(%Player{max_health: max_health} = player, %{affect: :heal}) do
    %{player | health: max_health}
  end

  def apply_effect(%Player{health: health} = player, %{affect: :hurt, modifier: modifier}) do
    %{player | health: health - modifier}
  end

  def apply_effect(%Player{attack: attack} = player, %{affect: :buff_attack, modifier: modifier}) do
    %{player | attack: attack + modifier}
  end
end
