defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  ## Examples
      iex>
  """
  def main(input) do
    input
    |> hash_string()
    |> pick_color()
    |> build_grid()
    |> filer_odd_squares()
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_string(input) do
    hex = :crypto.hash(:md5, input) |> :binary.bin_to_list()
    %Identicon.Image{hex: hex}
  end

  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  def filer_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {num, _index} ->
        rem(num, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_num, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50
        top_left = {horizontal, vertical}

        horizontal = horizontal + 50
        vertical = vertical + 50
        bottom_right = {horizontal, vertical}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, path) do
    File.write!("./img/#{path}.png", image)
  end
end