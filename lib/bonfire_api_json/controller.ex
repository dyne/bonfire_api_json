defmodule Bonfire.API.JSON.Controller do
  use Bonfire.Web, :controller

  import Bonfire.Common.Config, only: [repo: 0]

  alias Bonfire.Common.Pointers

  def get_objects(conn, %{"ids" => ids} = params) when is_list(ids) do
    objs = Enum.reduce(ids, [], fn id, acc ->
      case Pointers.get(id, skip_boundary_check: true) do
        {:ok, obj} ->
          obj = case obj do
            %ValueFlows.EconomicResource{} -> economic_resource(obj)
            %ValueFlows.EconomicEvent{} -> economic_event(obj)
            %ValueFlows.Process{} -> process(obj)
          end
          [obj | acc]
        {:error, :not_found} -> acc
      end
    end)

    unwind? = params["unwind"] == true
    json(conn, if unwind? do
      objs
    else
      %{data: objs}
    end)
  end

  def get_objects(conn, _) do
    json(conn, %{error: "bad params"})
  end

  def track(conn, %{"id" => id} = params) when is_binary(id) do
    limit = if (l = params["recurseLimit"]) && is_integer(l), do: l

    track = case Pointers.get(id, skip_boundary_check: true) do
      {:ok, obj} ->
        case obj do
          %ValueFlows.EconomicResource{} -> track_economic_resource(obj, limit)
          %ValueFlows.EconomicEvent{} -> track_economic_event(obj, limit)
          %ValueFlows.Process{} -> track_process(obj, limit)
        end
      {:error, :not_found} -> []
    end

    track = Enum.map(track, fn
      [] -> []
      %ValueFlows.EconomicResource{} = r -> economic_resource(r)
      %ValueFlows.EconomicEvent{} = e -> economic_event(e)
      %ValueFlows.Process{} = p -> process(p)
    end)

    unwind? = params["unwind"] == true
    json(conn, if unwind? do
      track
    else
      %{data: track}
    end)
  end

  def track(conn, _) do
    json(conn, %{error: "bad params"})
  end

  def trace(conn, %{"id" => id} = params) when is_binary(id) do
    limit = if (l = params["recurseLimit"]) && is_integer(l), do: l

    trace = case Pointers.get(id, skip_boundary_check: true) do
      {:ok, obj} ->
        case obj do
          %ValueFlows.EconomicResource{} -> trace_economic_resource(obj, limit)
          %ValueFlows.EconomicEvent{} -> trace_economic_event(obj, limit)
          %ValueFlows.Process{} -> trace_process(obj, limit)
        end
      {:error, :not_found} -> []
    end

    trace = Enum.map(trace, fn
      [] -> []
      %ValueFlows.EconomicResource{} = r -> economic_resource(r)
      %ValueFlows.EconomicEvent{} = e -> economic_event(e)
      %ValueFlows.Process{} = p -> process(p)
    end)

    unwind? = params["unwind"] == true
    json(conn, if unwind? do
      trace
    else
      %{data: trace}
    end)
  end

  def trace(conn, _) do
    json(conn, %{error: "bad params"})
  end

  defp track_economic_resource(res, nil) do
    {:ok, track} = ValueFlows.EconomicResource.EconomicResources.track(res)
    track
  end

  defp track_economic_resource(res, lim) do
    {:ok, track} = ValueFlows.EconomicResource.EconomicResources.track(res, lim)
    track
  end

  defp track_economic_event(evt, nil) do
    {:ok, track} = ValueFlows.EconomicEvent.EconomicEvents.track(evt)
    track
  end

  defp track_economic_event(evt, lim) do
    {:ok, track} = ValueFlows.EconomicEvent.EconomicEvents.track(evt, lim)
    track
  end

  defp track_process(proc, nil) do
    {:ok, track} = ValueFlows.Process.Processes.track(proc)
    track
  end

  defp track_process(proc, lim) do
    {:ok, track} = ValueFlows.Process.Processes.track(proc, lim)
    track
  end

  defp trace_economic_resource(res, nil) do
    {:ok, trace} = ValueFlows.EconomicResource.EconomicResources.trace(res)
    trace
  end

  defp trace_economic_resource(res, lim) do
    {:ok, trace} = ValueFlows.EconomicResource.EconomicResources.trace(res, lim)
    trace
  end

  defp trace_economic_event(evt, nil) do
    {:ok, trace} = ValueFlows.EconomicEvent.EconomicEvents.trace(evt)
    trace
  end

  defp trace_economic_event(evt, lim) do
    {:ok, trace} = ValueFlows.EconomicEvent.EconomicEvents.trace(evt, lim)
    trace
  end

  defp trace_process(proc, nil) do
    {:ok, trace} = ValueFlows.Process.Processes.trace(proc)
    trace
  end

  defp trace_process(proc, lim) do
    {:ok, trace} = ValueFlows.Process.Processes.trace(proc, lim)
    trace
  end

  defp economic_resource(%ValueFlows.EconomicResource{} = r) do
    r = repo().preload(r, [:primary_accountable, :onhand_quantity, :accounting_quantity, :current_location])

    %{
      __typename: "EconomicResource",
      id: r.id,
      resourceName: r.name,
      note: r.note,
      primaryAccountable: agent(r.primary_accountable),
      onhandQuantity: measure(r.onhand_quantity),
      accountingQuantity: measure(r.accounting_quantity),
      currentLocation: spatial_thing(r.current_location),
      trackingIdentifier: r.tracking_identifier,
    }
  end
  defp economic_resource(_), do: nil

  defp economic_event(%ValueFlows.EconomicEvent{} = e) do
    e = repo().preload(e, [
      :provider, :receiver,
      :resource_quantity, :effort_quantity,
      :resource_inventoried_as, :to_resource_inventoried_as,
      tags: :peered,
    ])

    %{
      __typename: "EconomicEvent",
      id: e.id,
      note: e.note,
      action: %{id: e.action_id},
      provider: agent(e.provider),
      receiver: agent(e.receiver),
      resourceQuantity: measure(e.resource_quantity),
      effortQuantity: measure(e.effort_quantity),
      resourceClassifiedAs: e.tags,
      resourceInventoriedAs: economic_resource(e.resource_inventoried_as),
      toResourceInventoriedAs: economic_resource(e.to_resource_inventoried_as),
    }
  end
  defp economic_event(_), do: nil

  defp process(%ValueFlows.Process{} = p) do
    p = repo().preload(p, [:inputs, :outputs])

    %{
      __typename: "Process",
      id: p.id,
      processName: p.name,
      note: p.note,
      inputs: Enum.map(p.inputs, &economic_event/1),
      outputs: Enum.map(p.outputs, &economic_event/1),
    }
  end
  defp process(_), do: nil

  defp agent(%Bonfire.Data.Identity.User{} = a) do
    a = repo().preload(a, [:character, :profile])

    %{
      id: a.id,
      name: a.profile.name,
      displayUsername: a.character.username,
    }
  end
  defp agent(_), do: nil

  defp spatial_thing(%Bonfire.Geolocate.Geolocation{} = st) do
    st = Bonfire.Geolocate.Geolocations.populate_coordinates(st)

    %{
      id: st.id,
      name: st.name,
      note: st.note,
      mappableAddress: st.mappable_address,
      alt: st.alt,
      long: st.long,
      lat: st.lat,
    }
  end
  defp spatial_thing(_), do: nil

  defp measure(%Bonfire.Quantify.Measure{} = m) do
    m = repo().preload(m, :unit)

    %{hasUnit: unit(m.unit), hasNumericalValue: m.has_numerical_value}
  end
  defp measure(_), do: nil

  defp unit(%Bonfire.Quantify.Unit{} = u) do
    Map.take(u, [:id, :label, :symbol])
  end
  defp unit(_), do: nil

  defp timestamp(ulid) do
    {:ok, ts} = Pointers.ULID.timestamp(ulid)
    ts
  end
end
