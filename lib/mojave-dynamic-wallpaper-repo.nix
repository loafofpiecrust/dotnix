{ pkgs }:
pkgs.fetchgit {
  url = "https://github.com/saint-13/Linux_Dynamic_Wallpapers";
  rev = "8904f832affb667c2926061d8e52b9131687451b";
  sparseCheckout = [ "Dynamic_Wallpapers/Mojave" ];
  sha256 = "VW1xOSLtal6VGP7JHv8NKdu7YTXeAHRrwZhnJy+T9bQ=";
}
