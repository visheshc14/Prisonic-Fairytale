defmodule Mmo.Player.Controller do
  def convert(%{"key" => "w"}) do
    :up
  end

  def convert(%{"key" => "a"}) do
    :left
  end

  def convert(%{"key" => "s"}) do
    :down
  end

  def convert(%{"key" => "d"}) do
    :right
  end

  def convert(_) do
    :error
  end
end
