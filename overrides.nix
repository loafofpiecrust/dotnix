{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      emacsCustom = super.emacs.override {
        withPgtk = true;
        withSQLite3 = true;
        # withWebP = true;
        withNativeCompilation = true;
      };
      beets = (super.python3.pkgs.beets.override {
        # Must bump the version whenever config changes to actually apply the new
        # build in the system config.
        pluginOverrides = {
          alternatives = {
            enable = true;
            # WARNING: MAKE SURE TO SPELL PROPAGATED CORRECTLY! THIS IS NOT TYPE-CHECKED!
            propagatedBuildInputs = [ self.python3.pkgs.beets-alternatives ];
          };
          dynamicrange = {
            enable = true;
            propagatedBuildInputs = [
              (self.python3Packages.buildPythonApplication rec {
                pname = "beets-dynamicrange";
                version = "unstable-2022-08-15";
                pyproject = true;
                build-system = [ self.python3.pkgs.setuptools ];

                # Use the branch that fixes FAT32 usage
                src = self.fetchFromGitHub {
                  owner = "auchter";
                  repo = "beets-dynamicrange";
                  rev = "62fc157f85293d1d2dcc36b5afa33d5322cc8c5f";
                  sha256 =
                    "sha256-ALNGrpZOKdUE3g4np8Ms+0s8uWi6YixF2IVHSgaQVj4=";
                };

                postPatch = ''
                  substituteInPlace beetsplug/dynamicrange.py \
                    --replace dr14_tmeter ${pkgs.dr14_tmeter}/bin/dr14_tmeter
                '';
                doCheck = false;

                nativeBuildInputs = with self;
                  [ self.python3.pkgs.beets-minimal ];

                propagatedBuildInputs = with self; [ dr14_tmeter ];
              })
            ];
          };
        };
      });
    })
  ];
}
