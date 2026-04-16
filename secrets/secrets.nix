let
  lagoon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4G1z6SbYjCyAkDoHo0unU2idrRRIT33UCWuAKeHArQ peppidesu@lagoon";
  ferry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgGkPR0z519KpHWGUdASL1vn1O+dazxuW7tjEL7hULh root@ferry";
in
{
  # Wireguard private key for Mullvad VPN
  "wg-key-mullvad.age".publicKeys = [ lagoon ];

  # Wireguard private key for home VPN via ferry.
  # Public key: xqhLjwC4Jngd9L6jp2C2QiSqPfCw+Sjo8KtLpmyq5lQ=
  "wg-key-ferry.age".publicKeys = [ ferry ];
}
