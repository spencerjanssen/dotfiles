{ pkgs, config, ... }:
{
  age.secrets.wireguard-mithlond.file = ../../secrets/wireguard-mithlond.age;
  networking.nat = {
    enable = true;
    externalInterface = "enp2s0";
    internalInterfaces = [ "wg0" ];
  };
  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 27089;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp2s0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      privateKeyFile = config.age.secrets.wireguard-mithlond.path;
      peers = [
        #cell phone
        {
          publicKey = "HqVZQS1cNFtDz64Qr8Cplq/lV/K/Apsn2ES3UpB383w=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        # surface book
        {
          publicKey = "9oiRJmGS7uAFUrAZWKtq2Ndq9FF9VB6O1kWG9G8dEy8=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };
}
