{
  # network discovery, mDNS
  services.avahi = {
    enable = true;
    # Only available on unstable
    # nssmdns4 = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };
}
