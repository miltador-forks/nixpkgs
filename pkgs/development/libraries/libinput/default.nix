{ stdenv, fetchurl, pkgconfig
, libevdev, mtdev, udev, libwacom
, documentationSupport ? false, doxygen ? null, graphviz ? null # Documentation
, eventGUISupport ? false, cairo ? null, glib ? null, gtk3 ? null # GUI event viewer support
, testsSupport ? false, check ? null, valgrind ? null
, autoconf, automake
}:

assert documentationSupport -> doxygen != null && graphviz != null;
assert eventGUISupport -> cairo != null && glib != null && gtk3 != null;
assert testsSupport -> check != null && valgrind != null;

let
  mkFlag = optSet: flag: if optSet then "--enable-${flag}" else "--disable-${flag}";
in

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "libinput-${version}";
  version = "1.5.1";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/libinput/${name}.tar.xz";
    sha256 = "d4f63933b0967bd691735af5e3919e2d29c2121d4e05867cc4e10ff3ae8e2dd8";
  };

  outputs = [ "out" "dev" ];

  configureFlags = [
    (mkFlag documentationSupport "documentation")
    (mkFlag eventGUISupport "event-gui")
    (mkFlag testsSupport "tests")
  ];

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ libevdev mtdev libwacom autoconf automake ]
    ++ optionals eventGUISupport [ cairo glib gtk3 ]
    ++ optionals documentationSupport [ doxygen graphviz ]
    ++ optionals testsSupport [ check valgrind ];

  propagatedBuildInputs = [ udev ];

  patches = [ ./udev-absolute-path.patch ];
  patchFlags = [ "-p0" ];

  meta = {
    description = "Handles input devices in Wayland compositors and provides a generic X.Org input driver";
    homepage    = http://www.freedesktop.org/wiki/Software/libinput;
    license     = licenses.mit;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ codyopel wkennington ];
  };
}
