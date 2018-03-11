defmodule BeaglePru.System do
  require Logger

  @moduledoc """
  BeagleBone Black/Green/Pocket PRU Helper Library
  """

  defguard is_valid_pru?(coreid) when coreid >= 0 and coreid <= 1

  def configure_pins do
    run("config-pin overlay cape-universal ")
    run("config-pin overlay cape-univ-hdmi ")
    :ok
  end

  def configure_rpmsg do
    run("modprobe rpmsg_pru")
    :ok
  end

  # Sysfs location from kernel 4.9
  def sysfs_path(0), do: "/sys/class/remoteproc/remoteproc1"
  def sysfs_path(1), do: "/sys/class/remoteproc/remoteproc2"
  def sysfs_path(id), do: raise("Unknown PRU: #{inspect(id)}")

  @doc """
  Load and boot a given firmware for on a given PRU processor core.

  Returns ':ok'

  ## Examples

  iex> BealgePru.System.boot 0
  :ok

  """
  def boot(core), do: boot(core, "am335x-pru#{core}-fw")

  def boot(core, firmware) when is_valid_pru?(core) do
    run("echo '#{firmware}' > #{sysfs_path(core)}/firmware")
    run("echo 'start' > #{sysfs_path(core)}/state")
    :ok
  end

  def boot(core, _firmware), do: raise("Unknown PRU: #{inspect(core)}")

  @doc """
  Stop a given PRU processor core.

  Returns ':ok'

  ## Examples

  iex> BealgePru.System.stop 0
  :ok

  """
  def stop(core) when is_valid_pru?(core) do
    run("echo 'stop' > #{sysfs_path(core)}/state")
    :ok
  end

  def stop(core), do: raise("Unknown PRU: #{inspect(core)}")

  @doc """
  Reboots a given PRU processor core.

  Returns ':ok'

  ## Examples

  iex> BealgePru.System.reboot 0
  :ok

  """
  def reboot(core) do
    :ok = stop(core)
    :ok = boot(core)
    :ok
  end

  @doc """
  Enables the specified pin for use as a GPIO output for the PRUs.

  Returns ':ok'

  ## Examples

  iex> BealgePru.System.pin 'P8_11', :out
  :ok

  iex> BealgePru.System.pin 'P8_11', :in
  :ok

  """
  def pin(pin, :pruout), do: set_pin(pin, :pruout)
  def pin(pin, :pruin), do: set_pin(pin, :pruin)
  def pin(pin, :input), do: set_pin(pin, :gpio_input)
  def pin(pin, :output), do: set_pin(pin, :gpio_output)
  def pin(pin, :gpio), do: set_pin(pin, :gpio)
  def pin(pin, cmd), do: set_pin(pin, cmd)

  def pin_info(pin) do
    import String

    case :os.cmd('config-pin -i #{pin}') do
      "Invalid pin:" <> _rem ->
        {:error, :invalid_pin, pin}
      "Pin is not modifyable:" <> _res ->
        {:ok, %{pin_modifyable: false}}
      response ->
        pin_info =
          response
          |> split("\n")
          |> Enum.each(fn s -> [k, v] = split(s, ":"); {k |> downcase() |> trim, v |> downcase |> trim} end)

        with {:ok, pin_name} <- Map.fetch(pin_info, "pin name"),
             {:ok, gpio_id} <- Map.fetch(pin_info, "kernel gpio id"),
             {:ok, gpio_number} <- gpio_id |> Integer.parse(),
             {:ok, pru_id} <- Map.fetch(pin_info, "pru gpio id"),
             {:ok, pru_number} <- pru_id |> Integer.parse(),
             {:ok, default_state} <- Map.fetch(pin_info, "function if no cape loaded"),
             {:ok, cape_funcs} <- Map.fetch(pin_info, "function if cape loaded"),
             {:ok, pin_funcs} <- Map.fetch(pin_info, "function information")
        do
          pin_info = %{
            name: pin_name,
            gpio_id: gpio_number,
            pru_id: pru_number,
            default: pin_funcs |> trim(),
            functions: %{
              standard: pin_funcs |> split(" "), 
              cape: cape_funcs |> split(" "),
              default: default_state,
            },
            status: :os.cmd('config-pin -q #{pin}')
          }
          {:ok, pin_info}
        end
    end
  end

  defp set_pin(pin, cmd) do
    run("config-pin #{pin} #{cmd}")
    :ok
  end

  def run(cmd) do
    Logger.info(:os.cmd(cmd |> to_charlist))
    :os.timestamp()
  end

  def run(cmd, :raw) do
    IO.puts(:os.cmd(cmd |> to_charlist))
    :os.timestamp()
  end
end
