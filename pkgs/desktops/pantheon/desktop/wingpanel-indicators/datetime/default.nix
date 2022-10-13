{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, nix-update-script
, substituteAll
, pkg-config
, meson
, python3
, ninja
, vala
, gtk3
, granite
, wingpanel
, evolution-data-server
, libical
, libgee
, libhandy
, libxml2
, libsoup
, libgdata
, elementary-calendar
}:

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-datetime";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "sha256-GxlnzLDrZmDDAGlUMoM4k4SkbCqra3Th6ugRAj3Wse4=";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      elementary_calendar = elementary-calendar;
    })

    # GridDay: Do not connect to the notify signal for the property
    # https://github.com/elementary/wingpanel-indicator-datetime/pull/305
    (fetchpatch {
      url = "https://github.com/elementary/wingpanel-indicator-datetime/commit/845ac1345124571fe995ab7138d5dfe4d29847e9.patch";
      sha256 = "sha256-/wd/FnhjC0c0Y8mCZg8XNoPOYAAmfK+g1F6L6TMEkdM=";
    })
  ];

  nativeBuildInputs = [
    libxml2
    meson
    ninja
    pkg-config
    python3
    vala
  ];

  buildInputs = [
    evolution-data-server
    granite
    gtk3
    libgee
    libhandy
    libical
    libsoup
    wingpanel
  ];

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = "pantheon.${pname}";
    };
  };

  meta = with lib; {
    description = "Date & Time Indicator for Wingpanel";
    homepage = "https://github.com/elementary/wingpanel-indicator-datetime";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.pantheon.members;
  };
}
