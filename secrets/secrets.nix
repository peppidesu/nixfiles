let
  lagoon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4G1z6SbYjCyAkDoHo0unU2idrRRIT33UCWuAKeHArQ peppidesu@lagoon";
in
{
  "wg-key-mullvad-server.age".publicKeys = [ lagoon ];
}
