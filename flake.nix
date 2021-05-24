{
  description = "project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; allowBroken = true; };
        overlays = [ self.overlay ];
      };
    in
    rec {
      overlay = final: prev: {
        # define overlays here, e.g.

        # myFlutter = prev.pkgs.flutterPackages.mkFlutter rec {
          # dart =
            # let version = "2.12.1";
            # in
            # prev.pkgs.dart.override {
              # inherit version;
              # sources = {
                # "${version}-x86_64-linux" = prev.pkgs.fetchurl {
                  # url =
                    # "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-x64-release.zip";
                  # sha256 = "sha256-Zt1OCQs07YOJ5eMpdXJLucTgpM66gSwqL43ZVlNhqXo=";
                # };
              # };
            # };
          # version = "2.0.3";
          # pname = "flutter";
          # src = prev.pkgs.fetchurl {
            # url =
              # "https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.0.3-stable.tar.xz";
              # sha256 = "sha256-lcUEXQc5GH2WHSS3MV5WLWuZjG73ZlqrfxmdOy8bRpE=";
          # };
          # patches = [./nix/flutter/patches/flutter.patch];
        # };
      };

      myHaskellPackages = pkgs.haskellPackages.override {
        overrides = hself: hsuper: {
          "project" =
            hself.callCabal2nix
              "project"
              (./.)
              { };
          };
      };

      devShell.${system} = myHaskellPackages.shellFor {
        # packages = p : [];
        packages = p: [ p.project ];
        buildInputs = [
          # haskell dev
          myHaskellPackages.cabal-install
          myHaskellPackages.hindent
          myHaskellPackages.ghci
          myHaskellPackages.haskell-language-server
          myHaskellPackages.hoogle
        ];
        # shellHook = ''
        #   <set environment varibales here>
        # '';
      };

      defaultPackage.${system} = myHaskellPackages.project;
    };
}
