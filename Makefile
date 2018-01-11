VERSION = 	0.3.4-snapshot
PKG = 		zlocker
MAIN = 		$(PKG).go
RM =		rm -f
DEP =		$(GOPATH)/bin/dep

.PHONY: all
all: $(PKG)

$(DEP):
	go get -u github.com/golang/dep/cmd/dep

.PHONY: deps
deps: $(DEP)
	$(DEP) ensure

$(PKG): deps
	go build

.PHONY: clean
clean:
	$(RM) $(PKG)
