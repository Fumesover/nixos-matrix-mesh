Fumesover's nix-config
======================

# Install a new remote host

This infects the server and restarts it with nixos

```bash
# OLD
nix run github:nix-community/nixos-anywhere -- --flake .#exo-nixos-2 --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --target-host root@2a04:c43:e00:92b9:45a:88ff:fe00:f00

# NEW
nix run github:nix-community/nixos-anywhere -- --flake .#nixos-tuwumesh-1 root@$IP
```

# Deploy to a remote host

```bash
# OLD
nixos-rebuild switch --flake .#exo-nixos-1 --sudo --target-host fumesover@exo.parou.eu --build-host localhost

# NEW
nix develop
deploy .#nixos-tuwumesh-1
```
