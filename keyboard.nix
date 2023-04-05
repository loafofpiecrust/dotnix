{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.kmonad.nixosModules.default ];
  environment.systemPackages = with pkgs; [
    keyd
    moused
    unstable.via
    unstable.vial
  ];
  services.udev.packages = with pkgs; [
    unstable.qmk-udev-rules
    unstable.via
    unstable.vial
  ];
  systemd.services.keyd = {
    enable = true;
    description = "key remapping daemon";
    wantedBy = [ "sysinit.target" ];
    requires = [ "local-fs.target" ];
    after = [ "local-fs.target" ];
    reloadTriggers = [ ./keyboard ];

    serviceConfig.type = "simple";
    script = "${pkgs.keyd}/bin/keyd";
  };
  systemd.services.moused = {
    enable = true;
    description = "mouse remapping daemon";
    wantedBy = [ "sysinit.target" ];
    requires = [ "local-fs.target" ];
    after = [ "local-fs.target" ];
    reloadTriggers = [ ./keyboard/mouse.conf ];

    serviceConfig.type = "simple";
    script = "${pkgs.moused}/bin/moused -f";
  };

  users.extraGroups.keyd = { };

  environment.etc."keyd/all-keyboards.conf".source =
    ./keyboard/all-keyboards.conf;
  environment.etc."moused.conf".source = ./keyboard/mouse.conf;

  nixpkgs.overlays = [
    (self: super: {
      keyd = super.keyd.overrideAttrs (old: {
        src = builtins.fetchurl {
          url =
            "https://github.com/rvaiya/keyd/archive/04c9e15d70fe1019dc5a38359540270caf86cfcb.tar.gz";
          sha256 = "171nrzrp1z8iiqh8x4cx3g0pxgnzxfidsrjwmaiiqb299d741biq";
        };
        buildInputs = old.buildInputs
          ++ [ (pkgs.writeShellScriptBin "git" ''echo "04c9e"'') ];
        postPatch = ''
          export DESTDIR=${placeholder "out"}
          substituteInPlace Makefile \
            --replace DESTDIR= DESTDIR=${placeholder "out"} \
            --replace /usr ""
          substituteInPlace keyd.service \
            --replace /usr/bin $out/bin
        '';
      });

      moused = self.stdenv.mkDerivation {
        pname = "moused";
        version = "1";
        src = self.fetchFromGitHub {
          owner = "rvaiya";
          repo = "moused";
          rev = "67275498908bbdfab3ea35151a9f54ed232e206d";
          hash = "sha256-nJTK+HoFAkMv90e6kMB/ZWcplenz7Vov+Rg1DyW9cFc=";
        };
        buildInputs = with pkgs; [ udev ];
        enableParallelBuilding = true;
        postPatch = ''
          mkdir -p $out/bin
          substituteInPlace Makefile \
            --replace /usr ${placeholder "out"} \
            --replace /etc ${placeholder "out"}/etc
        '';
        postInstall = "rm -rf $out/etc";
      };
    })
  ];

  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  # '';
  # nixpkgs.overlays = [
  #   (self: super: {
  #     keyd = super.keyd.overrideAttrs (old: {
  #       src = builtins.fetchGit {
  #         url = "https://github.com/rvaiya/keyd";
  #         rev = "04c9e15d70fe1019dc5a38359540270caf86cfcb";
  #       };
  #     });
  #   })
  # ];
}
