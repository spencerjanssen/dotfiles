{ config, pkgs, ... }:

{
  users.extraUsers.sidev = {
    isNormalUser = false;
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+x1cHtoqhvri6aNcisRKP5BKopXPDy7AiHM4NQIQkW+iFGGhwjaROLTL4/0e/sT2LdU963qd3CljVTcsWfxfMFUiWwBYfAOQsb/JaRbw/xprldLOaCGdCIGGRFu6PDxx5dsRFRcoeQEjXhaa9tOwb7s76qnAuYH12k7tWHt1TM8SVaHR2vFJ8MYbFZuMmj+hL+d3vVF1S+zZAC6aZVSWCSNFNHdWTnPlKe+CDjMTjQbyL58OL4eMm8jtqRxcOQBUBsFH0tQW5TQumdxRmKwWvKh1JZJ9QTkUg7dAc724uoFwxIUW88Cu4k9n+zrnWx1xZNoBqZ7F1nPVC17iMbXLVxinXArgwSSoCvx1x39yLO9RkFPJInZesxf1hSGpnk/GlhfWVxJTUwq0TtDHhRqWKnBzyGJ6oi9bGNjRA6xVAmYUyUJS1wFFJ37Tmt6nBGdYIFj6NGky0zoaUatfEHODzvVn6dodHPJYwkeWLzMLvyGOV+4GbF87FiUuUbH0StemPo1JlUn3P+uddeBnydtkeZpcr+RZVGc7PakN6/hrpjZcdnvpTh8V25GkvDf0kc2fJKFPG87C0JbRn1sdCA6hwaSL0eLKTTR80x52rMmPvSIqhe+qVe5a92bqGsCZJJcskAMfinyIRHjLnTmOoCyTqeUDkK4NnozFC0TvhYpAYAQ== sidev@CCA1-Dev01"
    ];
  };

  services.openssh.gatewayPorts = "yes";
}
