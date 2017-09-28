defmodule ExWire do
  @moduledoc """
  Main application for ExWire. We will begin listening on a port
  when this application is started.
  """

  @network_adapter Application.get_env(:ex_wire, :network_adapter)
  @port Application.get_env(:ex_wire, :port, 30303)
  @private_key Application.get_env(:ex_wire, :private_key)

  @type node_id :: binary()

  use Application

  @doc """
  Returns a private key that is generated when a new session is created. It is
  intended that this key is semi-persisted.
  """
  @spec private_key() :: ExthCrypto.Key.private_key()
  def private_key, do: @private_key
  def public_key do
    {:ok, public_key} = ExthCrypto.Signature.get_public_key(private_key())

    public_key
  end

  def start(_type, args) do
    import Supervisor.Spec

    network_adapter = Keyword.get(args, :network_adapter, @network_adapter)
    port = Keyword.get(args, :port, @port)
    name = Keyword.get(args, :name, ExWire)

    children = [
      worker(network_adapter, [{ExWire.Network, []}, port])
    ]

    opts = [strategy: :one_for_one, name: name]
    Supervisor.start_link(children, opts)
  end

end