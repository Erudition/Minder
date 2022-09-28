(use-package-modules base bash compression gcc gl glib linux nss pulseaudio
                     version-control virtualization xml xorg)
(use-modules (gnu packages gnome))
(use-modules (gnu packages llvm))
(use-modules (gnu packages gnome)) ;; for specification->

(packages->manifest
	(map 
		(compose list specification->package+output)
        	'("bash" "git" "which" "dbus" 
        	
        	;; Let's try fish
        	"fish"
        	"less" ;; fish fails without less on fish --help
        	
        	;; for debugging
        	"glibc" ;; for ldd
        	"patchelf"
        	"usbutils" ;; finding adb devices with lsusb
        	
        	;; for autopatchelf 
        	"util-linux" ;;  needing "getopt"
        	"file"
        	"ncurses" ;; needing "tput"
        	
        	
        	;; for Nativescript
        	"node"  ;; for npm
        	"nss-certs"  ;; fixes git/git-via-npm errors accessing HTTPS sites
        	
        	;; for elm-test
        	"tar"
        	
	;; for running the android virtual devices (AVD):
	"e2fsprogs" "qemu-minimal" ;; "adb" --jk use sdk one
        "alsa-lib" "expat" "libxcomposite" "libxcursor" "libxi" "libxtst"
        "mesa" "nss" "pulseaudio" "util-linux:lib" "libx11" "zlib" "gperftools"
        "gcc-objc:lib" "gcc-objc++:lib" "gcc-toolchain" "libcxx" "nspr" 
        "alsa-lib" "libxcomposite" 

	;; Errors on launch without these packages
	;;"clang@12.0.1:extra"

	;; Android Studio checks for these to launch:
	"grep" "coreutils" "findutils"
	"sed" "xmessage" "zenity"
	"openjdk@11:jdk" ;; formerly openjdk@11.28 but seems gone from guix. closest to the JDK 11 it comes bundled with
)))
