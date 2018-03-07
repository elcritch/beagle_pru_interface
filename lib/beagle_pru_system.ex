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
  def pin(pin, :out) do
    run("config-pin #{pin} pruout")
    :ok
  end

  def pin(pin, :in) do
    run("config-pin #{pin} pruin")
    :ok
  end

  def run(cmd) do
    IO.puts(:os.cmd(cmd |> to_charlist))
    :os.timestamp()
  end
end
