{ config, lib, pkgs, modulesPath, ... }:
let
  persistInEtc = [ "machine-id" "adjtime" "NIXOS" "nixos" ];
  withoutNulls = l: builtins.filter (e: e != null) l;
  persistOther = withoutNulls [
    "/var/lib/iwd"
    "/var/lib/upower"
    #"/var/lib/docker"
    #"/var/lib/bluetooth"
    "/var/lib/fprint"
  ];
in {
  # Save these files between boots by putting them on /persist
  # systemd.tmpfiles.rules = map (x: "L ${x} - - - - /persist${x}") persistOther;
  systemd.mounts = (map (path: {
    what = "/persist${path}";
    where = path;
    type = "none";
    options = "bind";
  }) persistOther);

  environment.etc = lib.mkMerge
    (map (name: { "${name}".source = "/persist/etc/${name}"; }) persistInEtc);

  system.activationScripts.etc.deps = [ "cp-etc" ];
  system.activationScripts.cp-etc = let
    etcLinks = (map (name: ''
      [ "/etc/${name}" -ef "/persist/etc/${name}" ] || cp -Trf {,/persist}/etc/${name}
    '') persistInEtc);
    otherLinks = (map (path: ''
      [ "${path}" -ef "/persist${path}" ] || cp -Trf ${path} /persist${path}
    '') persistOther);
  in ''
    mkdir -p /persist/etc
    mkdir -p /persist/var/lib
  '' + (builtins.concatStringsSep "\n" (etcLinks ++ otherLinks));

  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ /dev/nvme0n1p1 /mnt

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
