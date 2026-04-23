# Load before lib/shared-host-module.nix so nixpkgs config is fixed early.
{ lib, ... }: {
  nixpkgs.config.permittedInsecurePackages =
    [ "python-2.7.18.8" "openssl-1.1.1w" ];
  # Replace merged predicate (otherwise other modules' false arms block openssl here).
  nixpkgs.config.allowInsecurePredicate = lib.mkForce (pkg:
    let pname = pkg.pname or ""; in
    (pname == "openssl" && lib.versionOlder (pkg.version or "99") "3")
    || (pname == "python" && lib.hasPrefix "2.7" (pkg.version or ""))
    || builtins.elem pname [ "librewolf-bin" "librewolf-bin-unwrapped" ]);
}
