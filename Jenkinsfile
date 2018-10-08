@Library('jenkins-pipeline') _

repo = "exoscale/zlocker"

node {
  // Wipe the workspace so we are building completely clean
  cleanWs()

  try {
    dir('src') {
      stage('checkout source code') {
        checkout scm
      }
      updateGithubCommitStatus('PENDING', "${env.WORKSPACE}/src")
      stage('Build') {
        parallel (
          "go lint": {
            golint()
          },
          "docker build": {
            image = docker(repo)
          },
          "deb package": {
            build(repo)
            gitPbuilder('bionic')
          }
        )
      }

      stage('Upload') {
        parallel (
          "docker image": {
            image.push()
          },
          "deb package": {
            aptlyUpload('staging', 'bionic', 'main', '../build-area/*deb')
          }
        )
      }
    }
  }
  catch (err) {
    currentBuild.result = 'FAILURE'
    throw err
  }

  finally {
    if (currentBuild.result != 'FAILURE') {
      currentBuild.result = 'SUCCESS'
    }
    updateGithubCommitStatus(currentBuild.result, "${env.WORKSPACE}/src")
  }
}

def golint() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.pull()
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'golint -set_exit_status -min_confidence 0.6 $(go list github.com/exoscale/zlocker/... | grep -v /vendor/)'
      sh 'go vet $(go list github.com/exoscale/zlocker/... | grep -v /vendor/)'
    }
  }
}

def build(repo) {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'cd /go/src/github.com/exoscale/zlocker && CGO_ENABLED=0 go build -ldflags "-s -X main.version=`cat VERSION`"'
    }
  }
}

def docker(repo) {
  def branch = getGitBranch()
  def tag = getGitTag() ?: (branch == "master" ? "latest" : branch)
  def ref = sh("git rev-parse HEAD")
  def date = sh('date -u +"%Y-%m-%dT%H:%m:%SZ"')
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    return docker.build(
        "registry.internal.exoscale.ch/${repo}:${tag}",
        "--network host --no-cache -f Dockerfile "
        + "--build-arg VCS_REF=$ref --build-arg BUILD_DATE=$date "
        + "."
    )
  }
}
