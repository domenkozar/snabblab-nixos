let
  build-slave = { config, pkgs, ... }: {
    require = [
      ./../modules/common.nix
      ./../modules/hydra-slave.nix
    ];
    services.openssh.enable = true;
    # TODO: this is wrong, but just temporary
    fileSystems = [
      { mountPoint = "/"; fsType = "ext4"; label = "root"; }
    ];
    boot.loader.grub.devices = ["/dev/sda"];

  };
in {
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    require = [
      ./../modules/common.nix
      ./../modules/hydra-master.nix
    ];

    # User for nixops deployments
    users.extraUsers.deploy = {
      uid = 2001;
      description = "deploy";
      group = "deploy";
      isNormalUser = true;
      openssh.authorizedKeys.keys = config.users.extraUsers.domenkozar.openssh.authorizedKeys.keys;
    };
    users.extraGroups.deploy.gid = 2001;

    services.openssh.enable = true;

    # samba is used for ISO booting for lab servers
    users.extraUsers.smbguest = {
      uid = 2000;
      description = "smbguest";
      group = "smbguest";
    };
    users.extraGroups.smbguest.gid = 2000;

    networking.firewall.enable = true;
    services.samba = {
      enable = true;
      shares = {
        data =
          { path = "/mnt/samba";
            "read only" = "yes";
            browseable = "yes";
            "guest ok" = "yes";
          };
      };
      extraConfig = ''
        guest account = smbguest
        map to guest = bad user
      '';
    };

    environment.systemPackages = with pkgs; [
      nixops
    ];
  };
  build1 = build-slave;
  build2 = build-slave;
  build3 = build-slave;
  build4 = build-slave;
}
