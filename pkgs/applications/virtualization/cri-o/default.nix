{ stdenv
, btrfs-progs
, buildGoModule
, fetchFromGitHub
, glibc
, gpgme
, installShellFiles
, libapparmor
, libassuan
, libgpgerror
, libseccomp
, libselinux
, lvm2
, pkg-config
}:

buildGoModule rec {
  pname = "cri-o";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "cri-o";
    repo = "cri-o";
    rev = "v${version}";
    sha256 = "142flmv54pj48rjqkd26fbxrcbx2cv6pdmrc33jgyvn6r99zliah";
  };
  vendorSha256 = null;
  outputs = [ "out" "man" ];
  nativeBuildInputs = [ installShellFiles pkg-config ];

  buildInputs = [
    btrfs-progs
    gpgme
    libapparmor
    libassuan
    libgpgerror
    libseccomp
    libselinux
    lvm2
  ] ++ stdenv.lib.optionals (glibc != null) [ glibc glibc.static ];

  BUILDTAGS = "apparmor seccomp selinux containers_image_ostree_stub";
  buildPhase = ''
    sed -i '/version.buildDate/d' Makefile

    make binaries docs BUILDTAGS="$BUILDTAGS"
  '';

  installPhase = ''
    install -Dm755 bin/* -t $out/bin

    for shell in bash fish zsh; do
      installShellCompletion --$shell completions/$shell/*
    done

    installManPage docs/*.[1-9]
  '';

  meta = with stdenv.lib; {
    homepage = "https://cri-o.io";
    description = ''
      Open Container Initiative-based implementation of the
      Kubernetes Container Runtime Interface
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ ] ++ teams.podman.members;
    platforms = platforms.linux;
  };
}
