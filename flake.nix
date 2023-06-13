{
  description = "Inform programming language";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.default = pkgs.callPackage ./inform.nix {};

      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/inform7";
      };

      packages.inweb = pkgs.callPackage ./inweb.nix {};

      apps.inweb = {
        type = "app";
        program = "${self.packages.${system}.inweb}/bin/inweb";
      };
    }
  );
}
