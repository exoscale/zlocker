VERSION =   $(shell cat VERSION)
PKG =       zlocker
MAIN =      $(PKG).go
RM =        rm -f
DEP =       dep
SRCS =      zlocker.go
LINTOPTS =  -set_exit_status -min_confidence 0.6

.PHONY: all
all: $(PKG)

$(PKG):
	go build -mod=vendor -ldflags "-X main.version=$(VERSION)"

.PHONY: lint
lint:
	golint $(LINTOPTS) $(GOLIST)
	go vet $(GOLIST)

.PHONY: clean
clean:
	@$(RM) $(PKG)
