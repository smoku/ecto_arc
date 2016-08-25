defmodule EctoArc.Type do
  defmacro __using__(_options) do
    definition = __CALLER__.module

    quote do
      defmodule Module.concat(unquote(definition), "Type") do
        @behaviour Ecto.Type

        def type, do: :string

        def cast(value) do
          file = Arc.File.new(value)
          case unquote(definition).validate({file, nil}) do
            true ->
              file_name = Arc.Definition.Versioning.resolve_file_name(
                unquote(definition),
                :original,
                {file, nil}
              )
              {:ok, %{file_name: file_name, file: value}}
            _ ->
              :error
          end
        end

        def load(value) do
          {:ok, %{file_name: value}}
        end

        def dump(%{file_name: value}) do
          {:ok, value}
        end

      end
    end
  end
end
