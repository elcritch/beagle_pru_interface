defmodule BeaglePru.System do
  require Logger

  @moduledoc """
  BeagleBone Black/Green/Pocket PRU Helper Library
  """

  defguard is_valid_pru?(pruid) when pruid >= 0 and pruid <= 1

  def configure_pins do
    run("config-pin overlay cape-universal > /dev/null")
    run("config-pin overlay cape-univ-hdmi > /dev/null")
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
  def boot(pru, firmware \\ "am335x-pru#{pru}-fw") when is_valid_pru?(pru) do
    run("echo '#{firmware}' > #{sysfs_path(pru)}/firmware")
    run("echo 'start' > #{sysfs_path(pru)}/state")
    :ok
  end

  def boot(pru, _firmware \\ ""), do: raise("Unknown PRU: #{inspect(pru)}")

  @doc """
  Stop a given PRU processor core.

  Returns ':ok'

  ## Examples

  iex> BealgePru.System.stop 0
  :ok

  """
  def stop(pru) when is_valid_pru?(pru) do
    run("echo 'stop' > #{sysfs_path(pru)}/state")
    :ok
  end

  def stop(pru), do: raise("Unknown PRU: #{inspect(pru)}")

  @doc """
  Reboots a given PRU processor core.

  Returns ':ok'

  ## Examples

  iex> BealgePru.System.reboot 0
  :ok

  """
  def reboot(pru) do
    :ok = stop(pru)
    :ok = boot(pru)
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
    Logger.info(:os.cmd(cmd |> to_charlist))
    :os.timestamp()
  end
end
