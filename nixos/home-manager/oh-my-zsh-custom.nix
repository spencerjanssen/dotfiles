{stdenv, oh-my-zsh}:

stdenv.mkDerivation {
    name = "oh-my-zsh-custom";
    buildInputs = [ oh-my-zsh ];
    unpackPhase = ''
        mkdir ./themes
        cp ${oh-my-zsh}/share/oh-my-zsh/themes/robbyrussell.zsh-theme ./themes
    '';
    patches = [ ../patches/robby-russell-hostname.patch ];
    installPhase = ''
        mkdir -p $out/themes
        cp themes/robbyrussell.zsh-theme $out/themes
    '';
}