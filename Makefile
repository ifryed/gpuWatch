APP_NAME = GPUWatch
APP_BUNDLE = $(APP_NAME).app
DMG_NAME = GPUWatch.dmg
DMG_ROOT = dist/dmg
SWIFT_SOURCES = $(wildcard GPUWatch/Sources/*.swift)
SDK := $(shell xcrun --show-sdk-path)
SWIFTC := $(shell xcrun -f swiftc)

.PHONY: all run open dmg clean

all: $(APP_BUNDLE)

$(APP_BUNDLE): $(SWIFT_SOURCES) GPUWatch/Info.plist
	mkdir -p $(APP_BUNDLE)/Contents/MacOS $(APP_BUNDLE)/Contents/Resources
	cp GPUWatch/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	$(SWIFTC) -parse-as-library -O \
		-target arm64-apple-macos14.0 \
		-sdk $(SDK) \
		-framework SwiftUI -framework AppKit -framework IOKit \
		$(SWIFT_SOURCES) \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
	codesign --force --deep --sign - $(APP_BUNDLE)

run: all
	open $(APP_BUNDLE)

open: run

dmg: $(APP_BUNDLE)
	rm -rf $(DMG_ROOT) $(DMG_NAME)
	mkdir -p $(DMG_ROOT)
	cp -R $(APP_BUNDLE) $(DMG_ROOT)/
	ln -s /Applications $(DMG_ROOT)/Applications
	hdiutil create -volname "GPU Watch" -srcfolder $(DMG_ROOT) -ov -format UDZO $(DMG_NAME)
	rm -rf $(DMG_ROOT)

clean:
	rm -rf $(APP_BUNDLE) $(DMG_ROOT) $(DMG_NAME) dist
