#  $ nix-build '<nixpkgs>' -A dockerTools.examples.redis
#  $ docker load < result

 { pkgs, buildImage, buildLayeredImage, fakeNss, pullImage, shadowSetup, buildImageWithNixDb, pkgsCross, streamNixShellImage }:

let
  pkgs = import <nixpkgs> {};
  dockerTools = pkgs.dockerTools;
  pullImage = pkgs.pullImage;
  buildImage = pkgs.buildImage;
in
rec {
  nixFromDockerHub = pullImage {
    imageName = "nixos/nix";
    imageDigest = "sha256:85299d86263a3059cf19f419f9d286cc9f06d3c13146a8ebbb21b3437f598357";
    sha256 = "19fw0n3wmddahzr20mhdqv6jkjn1kanh6n2mrr08ai53dr8ph5n7";
    finalImageTag = "2.2.1";
    finalImageName = "nix";
  };
  onTopOfPulledImage = buildImage {
    name = "onTopOfPulledImage";
    tag = "latest";
    fromImage = nixFromDockerHub;
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      pathsToLink = [ "/bin" ];
      paths = [ pkgs.hello ];
    };
  };
}

