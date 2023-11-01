defmodule PasswordGenerator do
  @moduledoc """
  Generates random password depending on parameters, Module  main function is `generate(options)`.
  That function takes the options map.
  Options example:
        options = %{
          "length" => "5",
          "numbers" => "false",
          "uppercase" => "false",
          "symbols" => "false"
        }
  There are only 4 options, `length`, `numbers`, `uppercase`, `symbols`.
  """
  @allowed_options [:length, :numbers, :uppercase, :symbols]

  @doc """
  Generates password for given options:

  ## Examples
      options = %{
        "length" => "5",
        "numbers" => "false",
        "uppercase" => "false",
        "symbols" => "false"
      }
      iex> PasswordGenerator.generate(options)
      "abcde"

      options = %{
        "length" => "5",
        "numbers" => "true",
        "uppercase" => "false",
        "symbols" => "false"
      }
      iex> PasswordGenerator.generate(options)
      "abcd3"
  """

  @spec generate(options :: map()) :: {:ok, bitstring()} | {:error, bitstring()}
  def generate(options) do
    has_length = Map.has_key?(options, "length")
    validate_length(has_length, options)
  end

  defp validate_length(false, _options) do
    {:error, "Please provide a length"}
  end

  defp validate_length(true, options) do
    digits = Enum.map(0..9, &Integer.to_string(&1))
    length = options["length"]
    is_integer = String.contains?(length, digits)
    validate_length_is_integer(is_integer, options)
  end

  defp validate_length_is_integer(false, _options) do
    {:error, "Only integers allowed for length."}
  end

  defp validate_length_is_integer(true, options) do
    length = options["length"] |> String.trim() |> String.to_integer()
    options_without_length = Map.delete(options, "length")
    options_values = Map.values(options_without_length)

    are_options_boolean =
      options_values |> Enum.all?(fn x -> String.to_atom(x) |> is_boolean() end)

    validate_options_values_are_boolean(are_options_boolean, length, options_without_length)
  end

  defp validate_options_values_are_boolean(false, _length, _options) do
    {:error, "Only booleans allowed for options values."}
  end

  defp validate_options_values_are_boolean(true, length, options) do
    options_keys = included_options(options)
    invalid_options? = options_keys |> Enum.all?(&(&1 in @allowed_options))
    validate_options(invalid_options?, length, options_keys)
  end

  defp validate_options(false, _length, _options_keys) do
    {:error, "Only options allowed numbers, uppercase, symbols."}
  end

  defp validate_options(true, length, options_keys) do
    generate_strings(length, options_keys)
  end

  defp generate_strings(length, options_keys) do
    options_keys = [:lowercase_letter | options_keys]
    minimal_inclusions = include(options_keys)
    remaining_length = length - length(minimal_inclusions)
    random_strings = generate_random_string(remaining_length, options_keys)
    strings = minimal_inclusions ++ random_strings
    get_result(strings)
  end

  defp include(options_keys) do
    options_keys |> Enum.map(&get(&1))
  end

  defp get(:lowercase_letter) do
    <<Enum.random(?a..?z)>>
  end

  defp get(:uppercase) do
    <<Enum.random(?A..?Z)>>
  end

  defp get(:numbers) do
    Enum.random(0..9) |> Integer.to_string()
  end

  @symbols "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  defp get(:symbols) do
    symbols = @symbols |> String.split("", trim: true)
    Enum.random(symbols)
  end

  defp generate_random_string(length, options_keys) do
    Enum.map(1..length, fn _ -> Enum.random(options_keys) |> get() end)
  end

  defp get_result(strings) do
    result =
      strings |> Enum.shuffle() |> to_string()

    {:ok, result}
  end

  defp included_options(options) do
    Enum.filter(
      options,
      fn {_key, value} ->
        value
        |> String.trim()
        |> String.to_existing_atom()
      end
    )
    |> Enum.map(fn {key, _value} -> String.to_atom(key) end)
  end
end
