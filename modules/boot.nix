_:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };

      efi.canTouchEfiVariables = true;
    };

    # i9-14900KF: logical CPUs 8/9 share the physical core that produced
    # verified data corruption. Remove this workaround after CPU replacement.
    # Start with CPU 0 only, then enable the other CPUs before systemd starts.
    kernelParams = [ "maxcpus=1" ];
    postBootCommands = ''
      if [[ "$(cat /sys/devices/system/cpu/present)" != "0-31" ]] ||
         [[ "$(cat /proc/cpuinfo)" != *"i9-14900KF"* ]]; then
        echo "CPU workaround: unexpected hardware; retaining boot CPU only." >&2
      else
        for cpu in 8 9; do
          echo 0 > /sys/devices/system/cpu/cpu$cpu/online
        done
        for online in /sys/devices/system/cpu/cpu[0-9]*/online; do
          case "$online" in
            */cpu8/online|*/cpu9/online) continue ;;
          esac
          echo 1 > "$online"
        done
        echo "CPU workaround: online CPUs $(cat /sys/devices/system/cpu/online)"
      fi
    '';
  };
}
