defmodule Cards do
  @moduledoc """
    Provides methods for creating and handling a deck of cards
  """

  @doc """
    Returns a list of strings represtenting a deck of playing cards
  """
  def create_deck do
    faces = ["Ace", "Two", "Three", "Four", "Five"]
    suits = ["Spades", "Clubs", "Hearts", "Diamonds"]

    for suit <- suits, face <- faces do
      "#{face} of #{suit}"
    end
  end

  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
    Deteremines whether a deck conatins a given card

  ## Examples
      iex> deck = Cards.create_deck()
      iex> Cards.contains?(deck, "Ace of Spades")
      true
  """
  def contains?(deck, card) do
    Enum.member?(deck, card)
  end

  @doc """
    Divides a dekc into a hand anf the remainder of the deck.
    The `hand_size` argment indicates how many cards should
    be in the hand

  ## Examples
      iex> deck = Cards.create_deck
      iex> {hand, deck} = Cards.deal(deck,1)
      iex> hand
      ["Ace of Spades"]

  """
  def deal(deck, hand_size) do
    Enum.split(deck, hand_size)
  end

  def save(deck, path) do
    binary = :erlang.term_to_binary(deck)
    File.write(path, binary)
  end

  def load(path) do
    case File.read(path) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, _reason} -> "File does not exist or failed to load"
    end
  end

  def create_hand(hand_size) do
    create_deck() |> shuffle() |> deal(hand_size)
  end
end
