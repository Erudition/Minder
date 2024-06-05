all: VirtualDom Url Browser WebGL

VirtualDom:
	rm -f ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.3/artifacts.dat
	rm -f ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.3/docs.json
	patch -uN --no-backup-if-mismatch --reject-file=/tmp/rej ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.3/src/Elm/Kernel/VirtualDom.js ./VirtualDom.js.patch || true

Url:
	rm -f ~/.elm/0.19.1/packages/elm/url/1.0.0/artifacts.dat
	rm -f ~/.elm/0.19.1/packages/elm/url/1.0.0/docs.json
	patch -uN --no-backup-if-mismatch --reject-file=/tmp/rej ~/.elm/0.19.1/packages/elm/url/1.0.0/src/Url.elm ./Url.elm.patch || true

Browser:
	rm -f ~/.elm/0.19.1/packages/elm/browser/1.0.2/artifacts.dat
	rm -f ~/.elm/0.19.1/packages/elm/browser/1.0.2/docs.json
	patch -uN --no-backup-if-mismatch --reject-file=/tmp/rej ~/.elm/0.19.1/packages/elm/browser/1.0.2/src/Elm/Kernel/Browser.js ./PatchBrowserForFlipAnimations.patch || true

WebGL:
	rm -f ~/.elm/0.19.1/packages/elm-explorations/webgl/1.1.3/artifacts.dat
	rm -f ~/.elm/0.19.1/packages/elm-explorations/webgl/1.1.3/docs.json
	patch -uN --no-backup-if-mismatch --reject-file=/tmp/rej ~/.elm/0.19.1/packages/elm-explorations/webgl/1.1.3/src/Elm/Kernel/WebGL.js ./PatchWebGLForCanvasElement.patch || true