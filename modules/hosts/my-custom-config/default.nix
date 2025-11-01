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
                  # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
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
            };

            system.stateVersion = "25.05";
          }
        )
      ];
    };
  };
}
