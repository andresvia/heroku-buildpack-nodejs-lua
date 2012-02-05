
all:
	cd opt; make

test:: 
	-rm -r tmp-build
	mkdir -p tmp-build
	cp test/test_package.lua tmp-build/package.lua
	ENV=local bin/compile tmp-build
