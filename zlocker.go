package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/samuel/go-zookeeper/zk"
)

var sessionTimeout = flag.Int("t", 60, "Session timeout")
var waitPeriod = flag.Int("w", 1, "Wait period before releasing lock")
var zookeeperCluster = flag.String("z", "", "Address of zookeeper cluster")
var lockName = flag.String("l", "", "Name of zookeeper lock to request")

func main() {

	flag.Parse()

	logger := log.New(os.Stderr, "zlocker: ", 0)
	if len(*zookeeperCluster) == 0 || len(*lockName) == 0 {
		logger.Fatal("need a host and lock name")
	}

	servers := strings.Split(*zookeeperCluster, ",")
	cmdline := strings.Join(flag.Args(), " ")
	if len(cmdline) == 0 {
		logger.Fatal("nothing to run, exiting")
	}

	cluster, _, err := zk.Connect(
		servers,
		time.Second*time.Duration(*sessionTimeout),
		zk.WithLogger(logger))
	if err != nil {
		logger.Fatal("cannot connect to cluster")
	}
	defer cluster.Close()

	acl := zk.WorldACL(zk.PermAll)
	lock := zk.NewLock(cluster, *lockName, acl)
	if err = lock.Lock(); err != nil {
		logger.Fatal("cannot lock, exiting")
		os.Exit(1)
	}
	defer lock.Unlock()
	cmd := exec.Command("/bin/sh", "-c", cmdline)
	cmd.Stdout = os.Stdout
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	if err = cmd.Run(); err != nil {
		lock.Unlock()
		os.Exit(1)
	}
	if *waitPeriod > 0 {
		fmt.Println("command finished, sleeping")
		time.Sleep(time.Second * time.Duration(*waitPeriod))
	}
	lock.Unlock()
	os.Exit(0)
}
