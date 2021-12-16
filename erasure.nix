{ config, lib, pkgs, modulesPath, ... }:
let
  withoutNulls = l: builtins.filter (e: e != null) l;
  check = condition: value: if condition then value else null;
  persistOther = withoutNulls [
    (check config.networking.wireless.iwd.enable "/var/lib/iwd")
    (check config.services.upower.enable "/var/lib/upower")
    (check config.virtualisation.docker.enable "/var/lib/docker")
    (check config.services.fprintd.enable "/var/lib/fprint")
    # (check config.hardware.bluetooth.enable "/var/lib/bluetooth")
  ];
  persistInEtc = [
    "machine-id"
    "adjtime"
    "NIXOS"
    "nixos" # "bluetooth"
  ];
in {
  # Bind mount persisted folders onto the root partition at boot.
  # Several services don't like their state folders to be symlinks, so bind
  # mounts work better.
  systemd.mounts = (map (path: {
    what = "/persist${path}";
    where = path;
    type = "none";
    options = "bind";
  }) persistOther);

  # Let NixOS handle the persistent /etc files.
  environment.etc = lib.mkMerge
    (map (name: { "${name}".source = "/persist/etc/${name}"; }) persistInEtc);

  # Make sure any existing state is copied over to /persist before clobbering
  # the root subvolume.
  system.activationScripts.etc.deps = [ "cp-etc" ];
  system.activationScripts.cp-etc = let
    etcLinks = (map (name: ''
      [ -e "/persist/etc/${name}" ] || cp -Trf {,/persist}/etc/${name} || true
    '') persistInEtc);
    otherLinks = (map (path: ''
      [ -e "/persist${path}" ] || cp -Trf {,/persist}${path} || true
    '') persistOther);
  in ''
    mkdir -p /persist/etc
    mkdir -p /persist/var/lib
  '' + (builtins.concatStringsSep "\n" (etcLinks ++ otherLinks));

  # Erase all state files that weren't explicitly saved.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ ${config.fileSystems."/".device} /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.
    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';
}
