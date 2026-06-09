self: super: {
  farge = super.callPackage ./farge.nix { };
  cursor-agent-acp = super.callPackage ./cursor-agent-acp.nix { };
  frizbee = super.callPackage ./frizbee.nix { };
}
