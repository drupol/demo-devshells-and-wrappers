{ inputs, ... }:
{
  flake = {
    nixosConfigurations.my-custom-config = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        (
          { pkgs, ... }:
          {
            # This is needed in order to use `pkgs.local.nodejs14-bin` below.
            nixpkgs.overlays = [
              inputs.self.overlays.default
            ];

            boot.loader.systemd-boot.enable = true;

            fileSystems."/" = {
              device = "/dev/sda1";
              fsType = "ext4";
            };

            # Set your system kind (needed for flakes)
            nixpkgs.hostPlatform = "x86_64-linux";

            networking.hostName = "my-custom-config";

            environment.systemPackages = [
              pkgs.local.nodejs14-bin
            ];

            programs.fish.enable = true;

            # Configure your system-wide user settings (groups, etc), add more users as needed.
            users.users = {
              # FIXME: Replace with your username
              your-username = {
                shell = pkgs.fish;
                createHome = true;

                # TODO: You can set an initial password for your user.
                # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
                # Be sure to change it (using passwd) after rebooting!
                initialPassword = "id";
                isNormalUser = true;
                openssh.authorizedKeys.keys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfxTd6cA45DZPJsk3TmFmRPu1NQQ0XX0kow18mqFsLLaxiUQX1gsfW1kTVRGNh4s77StdsmnU/5oSQEXE6D8p3uEWCwNL74Sf4Lz4UyzSrsjyEEhNTQJromlgrVkf7N3wvEOakSZJICcpl05Z3UeResnkuZGSQ6zDVAKcB3KP1uYbR4SQGmWLHI1meznRkTDM5wHoiyWJnGpQjYVsRZT4LTUJwfhildAOx6ZIZUTsJrl35L2S81E6bv696CVGPvxV+PGbwGTavMYXfrSW4pqCnDPhQCLElQS4Od1qMicfYRSmk/W2oAKb8HZwFoWQSFUStF8ldQRnPyn2wiBQnhxnczt2jUhq1Uj6Nkq/edb1Ywgn7jlBR4BgRLD3K3oMvzJ/d3xDHjU56jc5lCA6lFLDMBV6Q9DKzMwL2jG3aQbehbUwTz7zbUwAHlCFIY5HGs4d9veXHyCsUikCLPvHL/hQU/vFRHHB7WNEyQJZK+ieOAW+un+1eF88iyKsOXE9y8PjLvXYcPHdzGaQKnqzEJSQcTUw9QSzOZQQpmpy8z6Lf08D2I4GHq1REp6d4krJOOW0gXadjsGEhLqQqWGnHE47QBPnlHlDWzOaf3UX59rFsl8xZDXoXzzwJ1stpeJx+Tn/uSNnaf44yXFyeFK/IDUeOrXYD4fSTLP1P/lCFCfeYqw== (none)"
                ];
                # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
                extraGroups = [ "wheel" ];
              };
            };

            # This setups a SSH server. Very important if you're setting up a headless system.
            # Feel free to remove if you don't need it.
            services.openssh = {
              enable = true;
              settings = {
                # Opinionated: forbid root login through SSH.
                PermitRootLogin = "no";
                # Opinionated: use keys only.
                # Remove if you want to SSH using passwords
                PasswordAuthentication = false;
              };
              openFirewall = true;
            };

            services.caddy = {
              enable = true;
              virtualHosts."http://" = {
                extraConfig = ''
                  respond "Hello World!"
                '';
              };
            };

            networking.firewall.allowedTCPPorts = [
              22
              80
            ];

            system.stateVersion = "25.05";
          }
        )
      ];
    };
  };
}
