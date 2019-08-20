{ config, pkgs, ... }:
let btrfs-backup-sync = (import (pkgs.fetchFromGitHub {
            owner = "spencerjanssen";
            repo = "btrfs-backup-sync";
            rev = "b25b0d60a4774dc1543d82676307857819dfecb1";
            sha256 = "18invszz12wmcj3qadhppi1l1l3zgjzb3b3j2fc77i687bgzzcvj";
        }) {nixpkgs = pkgs;}).btrfs-backup-sync;
in
{
    systemd.services.btrfs-backup-sync = {
        description = "sync btrfs snapshots to a backup drive";
        path = [btrfs-backup-sync pkgs.btrfs-progs pkgs.systemd];
        startAt = "hourly";
        script = ''
            echo syncing @nixos
            systemd-inhibit --who=btrfs-backup-sync-nixos --mode=block \
                btrfs-backup-sync real /media/evo/@nixos/.snapshots /media/blue/backups/ungoliant/@nixos/.snapshots
            echo done syncing @nixos
            echo syncing @home
            systemd-inhibit --who=btrfs-backup-sync-home --mode=block \
                btrfs-backup-sync real /media/evo/@home/.snapshots /media/blue/backups/ungoliant/@home/.snapshots
            echo done syncing @home
        '';
        after = ["snapper-timeline.service"];
    };
}