# Adding 3rd party dependency as a submodule.

- Add new framework to Library project targets
- Remove added framework folder from Library project

For added framework 

- Remove in build settings:
	- Reference to info.plist 
	- Code Signing Identity
	- Code Signing Style
- Remove all build phases
- Add runscript build phase:
	- Add Shell script `bash ${SRCROOT}/copy-framework.sh`
	- Add Input Files `$(SRCROOT)/${PLATFORM_NAME}/${PRODUCT_NAME}.framework`
	- Add Output Files `${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework`

You need to add the new framework to all dependent projects like safe, safeUIKIt, unit tests and UI test targets where it needed.