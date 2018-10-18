VERSION =   $(shell cat VERSION)
PKG =       zlocker
MAIN =      $(PKG).go
RM =        rm -f

.PHONY: all
all: $(PKG)

$(PKG): test
	go build -mod=vendor -ldflags "-X main.version=$(VERSION)"

.PHONY: test
test:
	go test

.PHONY: lint
lint:
	golangci-lint run

.PHONY: clean
clean:
	@$(RM) $(PKG)
