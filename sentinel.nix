let
  pkgs = import <nixpkgs> {};
  dockerTools = pkgs.dockerTools;
in
dockerTools.buildImage {
  name = "sentinel";
  tag = "latest";
  copyToRoot = [ pkgs.nodejs-16_x ];
  config = {
    Cmd = [ "node" "main.js" ];
    runAsRoot = ''
      #!${pkgs.runtimeShell}
      ${pkgs.dockerTools.shadowSetup}
      groupadd -r node
      useradd -r -g node node
      mkdir /app/data && chown node:node /app/data
    '';
    Entrypoint = [ "/sbin/tini" "--" ];
    Env = [ "NODE_ENV=production" ];
    WorkingDir = "/app";
  };
}