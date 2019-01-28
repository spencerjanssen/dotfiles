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
        path = [btrfs-backup-sync pkgs.btrfs-progs];
        startAt = "hourly";
        script = ''
            btrfs-backup-sync real /media/evo/@nixos/.snapshots /media/blue/backups/ungoliant/@nixos
            btrfs-backup-sync real /media/evo/@home/.snapshots /media/blue/backups/ungoliant/@home
        '';
        after = ["snapper-timeline.service"];
    };
}