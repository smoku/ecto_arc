defmodule EctoArc do

  def store(model_or_models) when is_map(model_or_models) or is_list(model_or_models) do
    uploaders = extract_arc_uploaders(model_or_models)

    uploaders
    |> Enum.map(fn(uploader) -> async_uploader_store(uploader) end)
    |> Enum.map(fn(task) -> Task.await(task, version_timeout) end)
    |> handle_response
  end

  def store!(model_or_models) when is_map(model_or_models) or is_list(model_or_models) do
    {:ok} = store(model_or_models)
  end

  def async_store(model_or_models) when is_map(model_or_models) or is_list(model_or_models) do
    Task.Supervisor.async_nolink(Recruitee.TaskSupervisor, fn ->
      store(model_or_models)
    end)
  end

  defp extract_arc_uploaders(models) when is_list(models) do
    models |> Enum.flat_map(fn(model) -> extract_arc_uploaders(model) end)
  end

  defp extract_arc_uploaders(model_or_changeset) when is_map(model_or_changeset) do
    model =
      case model_or_changeset do
        %Ecto.Changeset{} -> Ecto.Changeset.apply_changes(model_or_changeset)
        %{__meta__: _} -> model_or_changeset
      end

    model
    |> Map.keys
    |> Enum.reduce([], fn(key, list) ->
      case Map.get(model, key) do
        %{file_name: _, file: file} ->
          definition =
            model.__struct__.__schema__(:type, key)
            |> Atom.to_string
            |> String.replace_suffix(".Type", "")
            |> Module.concat(nil)
          list ++ [%{definition: definition, scope: model, file: file}]
        _ ->
          list
      end
    end)
  end

  defp async_uploader_store(uploader) do
    Task.async(fn ->
      uploader.definition.store({uploader.file, uploader.scope})
    end)
  end

  defp version_timeout do
    Application.get_env(:arc, :version_timeout) || 30_000
  end

  defp handle_response(responses) do
    errors =
      responses
      |> Enum.filter(fn(response) -> elem(response, 0) == :error end)
      |> Enum.map(fn(error) -> elem(error, 1) end)
    if Enum.empty?(errors) do
      {:ok}
    else
      {:error, errors}
    end
  end

end
