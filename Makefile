.POSIX:
.SUFFIXES:

LIBS=-lc -lGL -lOpenGL

clean:
	rm -rf docs

docs:
	mkdir -p docs/gl/
	haredoc -Fhtml gl > docs/gl/index.html


.PHONY: clean docs
