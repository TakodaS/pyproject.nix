{ pkgs, pyproject-nix }:

let
  hacks = pkgs.callPackages pyproject-nix.build.hacks { };
in
{
  nixpkgsPrebuilt =
    let
      drv = hacks.nixpkgsPrebuilt {
        from = pkgs.python3Packages.build;
        prev = {
          passthru = { };
        };
      };

    in
    pkgs.runCommand "nixpkgsPrebuilt-check" { } ''
      # Check that we only have one file in bin
      test $(ls ${drv}/bin | wc -l) -eq 1

      # Check that file does not contain any store references apart from shebang
      tail -n +2 ${drv}/bin/pyproject-build > script
      ! grep "${builtins.storeDir}" script

      ln -s ${drv} $out
    '';

}
