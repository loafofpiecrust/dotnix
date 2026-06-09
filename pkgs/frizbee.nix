{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage {
  pname = "frizbee";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "saghen";
    repo = "frizbee";
    rev = "v0.9.0";
    hash = "sha256-ugzCGm/UsGgq8QQrokikx5FwCJg+c1l5YKEbIju933g=";
  };

  cargoHash = "sha256-UbRZzzvVoNsyi/lKryNjTehC6lYlVWakoOQ7R7f+hP8=";

  meta = with lib; {
    description = "Fast typo-resistant fuzzy matching via SIMD smith waterman";
    homepage = "https://github.com/saghen/frizbee";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
