# Module: Networking
#
# NetworkManager, firewall, and crab-hole DNS ad-blocking.
#
# Extracted from: modules/services.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Network Services
  # ═══════════════════════════════════════════════════════════════════
  
  networking = {
    # Cloudflare DNS (encrypted via DoT) - handled by crab-hole
    nameservers = [ "127.0.0.1" ];
    
    networkmanager = {
      enable = true;
      wifi.powersave = false;  # Prevents WiFi disconnects
      dns = "none";  # crab-hole handles DNS
    };
    
    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      
      # Allow KDE Connect, Syncthing, etc. if needed
      allowedTCPPortRanges = [
        # { from = 1714; to = 1764; }  # KDE Connect
      ];
      allowedUDPPortRanges = [
        # { from = 1714; to = 1764; }  # KDE Connect
      ];
    };
  };

  # systemd-resolved disabled - crab-hole handles DNS
  services.resolved.enable = false;

  # ══════════════════════════════════════════════════════════════════
  # crab-hole - DNS-level ad/tracker blocking with DoT
  # ══════════════════════════════════════════════════════════════════
  
  services.crab-hole = {
    enable = true;
    
    settings = {
      # Blocklists
      blocklist = {
        include_subdomains = true;
        lists = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt"
        ];
      };
      
      # Listen on localhost
      downstream = [
        {
          protocol = "udp";
          listen = "127.0.0.1";
          port = 53;
        }
        {
          protocol = "udp";
          listen = "::1";
          port = 53;
        }
      ];
      
      # Cloudflare DoT upstream (encrypted!)
      upstream = {
        name_servers = [
          {
            socket_addr = "1.1.1.1:853";
            protocol = "tls";
            tls_dns_name = "1dot1dot1dot1.cloudflare-dns.com";
            trust_nx_responses = false;
          }
          {
            socket_addr = "1.0.0.1:853";
            protocol = "tls";
            tls_dns_name = "1dot1dot1dot1.cloudflare-dns.com";
            trust_nx_responses = false;
          }
        ];
        # Disable DNSSEC validation (compatibility)
        options = {
          validate = false;
        };
      };
    };
  };
}
