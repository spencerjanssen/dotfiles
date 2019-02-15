{ config, pkgs, ... }:
let btrfs-backup-sync = (import (pkgs.fetchFromGitHub {
            owner = "spencerjanssen";
            repo = "btrfs-backup-sync";
            rev = "d2beafecb46c576c4d6b7931a0a7b7efb9d0249b";
            sha256 = "0cqbdf92q3rchhs6257wq4qnz3hvsms1m8qy3sgh1g4bzhyfc76b";
        }) {}).btrfs-backup-sync;
in
{
    systemd.services.btrfs-backup-sync = {
        description = "sync btrfs snapshots to a backup drive";
        path = [btrfs-backup-sync pkgs.btrfs-progs pkgs.systemd];
        startAt = "hourly";
        script = ''
            echo syncing @nixos
            systemd-inhibit --who=btrfs-backup-sync-nixos --mode=block \
                btrfs-backup-sync real /media/evo/@nixos/.snapshots /media/blue/backups/ungoliant/@nixos
            echo done syncing @nixos
            echo syncing @home
            systemd-inhibit --who=btrfs-backup-sync-home --mode=block \
                btrfs-backup-sync real /media/evo/@home/.snapshots /media/blue/backups/ungoliant/@home
            echo done syncing @home
        '';
        after = ["snapper-timeline.service"];
    };
}