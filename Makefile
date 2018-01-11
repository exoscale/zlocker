VERSION = 	0.3.4-snapshot
PKG = 		zlocker
MAIN = 		$(PKG).go
RM =		rm -f

.PHONY: all
all: $(PKG)

$(GOPATH)/bin/dep:
	go get -u github.com/golang/dep/cmd/dep

.PHONY: deps
deps: $(GOPATH)/bin/dep
	dep ensure

$(PKG): deps
	go build

.PHONY: clean
clean:
	$(RM) $(PKG)
