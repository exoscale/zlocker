VERSION = 	v0.1.6-snapshot
PKG = 		zlocker
MAIN = 		$(PKG).go
RM =		rm -f
DEP =		dep

.PHONY: all
all: $(PKG)

$(DEP):
	@env -u GOOS -u GOARCH go get -u github.com/golang/dep/cmd/dep

.PHONY: deps
deps: $(DEP)
	@env PATH="$(GOPATH)/bin:$(PATH)" $(DEP) ensure

$(PKG): deps
	@env GCO_ENABLED=0 go build -ldflags "-s -X main.version=$(VERSION)"

.PHONY: clean
clean:
	@$(RM) $(PKG)

.PHONY: version
version:
	@echo $(VERSION)
