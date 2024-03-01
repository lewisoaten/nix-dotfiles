let
  lewis = "ssh-ed25519 invalid lewis@llt";
  llt = "ssh-ed25519 invalid root@llt";
in {
  "spotify.age".publicKeys = [lewis llt];
}
