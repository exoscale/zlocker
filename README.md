zlocker: zookeeper based isolated command execution
===================================================

:warning: Usage of this tool is deprecated and being replaced by `consul lock`.

[![Build Status](https://travis-ci.org/pyr/zlocker.svg?branch=master)](https://travis-ci.org/pyr/zlocker)

**zlocker** is a small tool meant to ease sequential execution of
a command across a large number of hosts.

## Configuration

**zlocker** is configured through command line arguments:

    -z
        Comma-separated list of zookeeper servers to contact
    -l
        Name of lock node in zookeeper
    -w
        Optional sleep period, defaults to none
    -t
	    Zookeeper session timeout

The rest of the command line will be fed to the shell if a lock
is successfully acquired.

## Building

If you wish to inspect **zlocker** and build it by yourself, you may do so
by cloning [this repository](https://github.com/pyr/zlocker) and
peforming the following steps :

    go build

### Example usage

    zlocker -z zk01,zk02,zk03 -l /zlock-service-restart service my-daemon restart
