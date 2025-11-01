{ inputs, ... }:
{
  flake = {
    nixosConfigurations.my-custom-config = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        (
          { pkgs, ... }:
          {
            nixpkgs = {
              hostPlatform = "x86_64-linux";
              overlays = [
                inputs.self.overlays.default
              ];
            };

            boot.loader.systemd-boot.enable = true;

            fileSystems."/" = {
              device = "/dev/sda1";
              fsType = "ext4";
            };

            networking = {
              hostName = "my-custom-config";
              firewall.allowedTCPPorts = [
                80
              ];
            };

            environment.systemPackages = [
              pkgs.local.nodejs14-bin
              pkgs.local.active-php-version
            ];

            programs.fish.enable = true;

            users.users.root.initialPassword = "id";
            users.users.root.shell = pkgs.fish;

            services.caddy = {
              enable = true;
              virtualHosts."http://" = {
                extraConfig = ''
                  respond "Hello World!"
                '';
              };
            };

            system.stateVersion = "25.05";
          }
        )
      ];
    };
  };
}
