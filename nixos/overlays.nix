[
    # work around issue with taffybar
    # https://github.com/haskell-gi/haskell-gi/issues/212
    # https://bugzilla.opensuse.org/show_bug.cgi?id=1121456
    # https://gitlab.gnome.org/GNOME/gtk/merge_requests/505/diffs
    (_self: super: {
        gtk3 = super.gtk3.overrideAttrs (old: {
            patches = old.patches ++ [(super.fetchpatch {
                url = "https://gitlab.gnome.org/GNOME/gtk/commit/a52431d2b42f3b458a3a2142f6f3e2c4501c1ccc.diff";
                sha256 = "0rm2r15k8gwzh27lima7s649kwr90p6z72lnfab303zxhzz4i3ms";
            })];
        });
    })
    (_self: super: {
        pidgin-with-plugins = super.pidgin-with-plugins.override {
            plugins = [super.pidginsipe];
        };
    })
]