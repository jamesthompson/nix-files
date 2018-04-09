{ lib, pkgs, vm-version, imprts ? [], ... }:
{
  imports = imprts;

  boot.vesa = false;

  virtualbox.baseImageSize = 100 * 1024;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  systemd.services.dhcpcd.restartIfChanged = false;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.hostName = "devvm";

  services.journald.extraConfig = "SystemMaxUse=100M";

  services.openssh = {
    enable = true;
    extraConfig = ''
      PermitRootLogin no
      GatewayPorts no
      PasswordAuthentication no
      PubkeyAuthentication yes
      ChallengeResponseAuthentication yes
      MaxAuthTries 4
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      PermitUserEnvironment no
      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
      ClientAliveInterval 300
      ClientAliveCountMax 1
      LoginGraceTime 30
      AllowUsers james
      LogLevel INFO
    '';
  };

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;
  programs.bash.enableCompletion = true;
  sound.enable = false;
  environment.systemPackages = with pkgs; [
    haskellPackages.cabal-install
  ];

  environment.variables = {
    VM_COMMIT = vm-version;
  };

  services.emacs = {
    enable = true;
    install = true;
    defaultEditor = true;
  };

  users.extraUsers.james = {
    isNormalUser = true;
    description = "James R. Thompson";
    extraGroups = [
      "disk"
      "messagebus"
      "networkmanager"
      "systemd-journal"
      "wheel"
      "vboxsf"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqPs18Dqm6+uehw+U4o8Rx0i80KmPMrVwJmAVFb0pXL8+qkbKnu2Qb6WOWcwnMfz6Glf7s7N9oM0El1KgIZOFrAUHCfVDToTeKQxMso+sSwrb+1uD8hKiFWj/mQulcrXgZGOEIOXawuekQ3IIEOO3/wWI6/JkMwXkX/AsxkwlzpQGHqnREzhvBaamdLosJtYgMm9spjQHrEq+rzNZdZVwT15rlDLvgXWYtiddkc4TVo7yLfW2sqPV5OWwVUcZ3bhUvhn07yJUpgDn+rb4J3HWedPjhoqAgz/CV8I/0Y5ChP0q+P8tuTB9s3atBm3ac9Y/SAYYE0K/DRvzp+L1nle7USIcrKATFx3jtcVjv+gJ3+8bCjrd/R+jZSvaYBKIs2QUslEdZ4O2zGZq+W2wKTKlbapadmNpN75N/KRQhUzgNhWaEzCTM746B5M9sKveBDl7ur0+5JlHpmXQXlbb11c/nC+hFMp9N7dA6WTEPc5LVhSDsHFNd7OUk4BfRO2Z8YsGh/WWGeUtSRGQK9a4nnNPpqxdZnt8adpGBq6Ef1eDUvpD//O4D3gJTIHOc1M0AQr0VM0eC2Fh0b7ElI6ZKCvtEiiUZ3DSp5o5drwQvjbwDBLH8u7Vo0LZITvGBQIAor6Y6or+9NLjrIjN8XmBCLbGuQxTIOOMMiJKoD2c/XgWG5w== james@doctrly.com"
    ];
    uid = 1000;
  };

}
