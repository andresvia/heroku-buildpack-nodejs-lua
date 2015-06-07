
all:
	cd opt; make

test:: 
	-rm -rf tmp-build
	mkdir -p tmp-build
	cp test/package.rockspec tmp-build/
	ENV=local STACK=cedar bin/compile tmp-build
