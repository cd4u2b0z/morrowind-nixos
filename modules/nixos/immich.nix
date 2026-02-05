# Module: Immich Client
#
# CLI tools for uploading photos/videos to a remote Immich server.
#
# First-time setup:
#   immich login http://your-immich-server:2283 your-api-key
#
# Usage:
#   immich upload ~/Pictures/Camera/
#   immich upload --album "Vacation 2026" ~/Pictures/vacation/
#   immich upload --recursive ~/Pictures/

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    immich-cli       # Official CLI for Immich
  ];
}
