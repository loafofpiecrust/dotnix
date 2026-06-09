# To update, bump rev/version and set hashes to "" (empty string). Build will
# fail with "hash mismatch" errors showing the correct hashes to paste back in.
# Example:  nix-build -E 'with import <nixpkgs> {}; callPackage ./cursor-agent-acp.nix {}'
{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "cursor-agent-acp";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "blowmage";
    repo = "cursor-agent-acp-npm";
    rev = "caf3583f550b776475d5c7a129c584fb9be7d450";
    hash = "sha256-k1DBiBVyjKHnVsvXWACuWc1y9SqEp5mLT253L/xakkU=";
  };

  npmDepsHash = "sha256-prT/vy1jYBiQ+8lurk1kAeTvXeNj22ftQe3p+n9q0AM=";

  buildPhase = ''
    npm run build
  '';

  meta = with lib; {
    description = "Agent Client Protocol (ACP) adapter for Cursor CLI";
    homepage = "https://github.com/blowmage/cursor-agent-acp-npm";
    license = licenses.mit;
    mainProgram = "cursor-agent-acp";
  };
}
