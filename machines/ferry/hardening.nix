{...}: {
  # Hide kptrs even for processes with CAP_SYSLOG
  boot.kernel.sysctl."kernel.kptr_restrict" = "2";

  # Disable ftrace debugging
  boot.kernel.sysctl."kernel.ftrace_enabled" = false;

  # Enable strict reverse path filtering (that is, do not attempt to route
  # packets that "obviously" do not belong to the iface's network; dropped
  # packets are logged as martians).
  boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = true;
  boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = "1";
  boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = true;
  boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = "1";

  # Ignore broadcast ICMP (mitigate SMURF)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = true;

  # Ignore incoming ICMP redirects (note: default is needed to ensure that the
  # setting is applied to interfaces added after the sysctls are set)
  boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

  # Ignore outgoing ICMP redirects (this is ipv4 only)
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25" "netrom" "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs" "affs"
    "bfs" "befs"
    "cramfs"
    "efs" "erofs" "exofs"
    "freevxfs" "f2fs"
    "hfs" "hpfs"
    "jfs"
    "minix"
    "nilfs2" "ntfs"
    "omfs"
    "qnx4" "qnx6"
    "sysv"
    "ufs"
  ];

  security.protectKernelImage = true;

  # AppArmor
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };

  # DO NOT ENABLE!!!
  # RPi bricker
  #
  # environment.memoryAllocator.provider = "graphene-hardened";
}
