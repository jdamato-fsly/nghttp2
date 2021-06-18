#!/usr/bin/env groovy

final def BUILD_TIMEOUT = 120
final def NODELABEL = 'docker-build'
final def RELEASE_BRANCH = 'fastly-stable'

def releaseBranches = [RELEASE_BRANCH, 'origin/' + RELEASE_BRANCH]
def cache = true
def cleanMergedRefs = false
def pushDeb = false
def namedBuild = null
def tagName = null
def slackChannel = null
def emailToSlack = [
  'jdamato@fastly.com': '@jdamato',
]

String getCleanedUpBuildRef() {
  String ref = getBuildRef().name
  def match = (ref =~ /^origin\/(.*)/)
  if (match) {
    ref = match[0][1]
  }
  return ref;
}


String ref = getCleanedUpBuildRef()
if (ref in releaseBranches) {
  pushDeb = true
  cache = false
  cleanMergedRefs = true
  tagName = "jenkins/release"
  slackChannel = '#cpuly'
} else if (ref =~ /^.*\/jenkins$/) {
  pushDeb = true
  cache = false
  namedBuild = ref.replaceAll("/jenkins", "").replaceAll('/', '-')
  slackChannel = emailToSlack[params.author_email]
  tagName = "jenkins/named"
} else if (ref =~ /^.*-stable$/) {
  pushDeb = true
  cache = false
  namedBuild = ref.replaceAll("-stable", "").replaceAll('/', '-')
  slackChannel = emailToSlack[params.author_email]
  tagName = "jenkins/stable"
} else {
  namedBuild = ref.replaceAll('/', '-')
}


fastlyPipeline(script: this, buildTimeout: BUILD_TIMEOUT, ignoreTags: true, slackChannel: slackChannel) {
  getNode(label: NODELABEL) {
    checkoutWithSubmodules scm
    def v = readFile file: './VERSION'
    def package_version = "${v.trim()}.${env.BUILD_NUMBER}"
    if (namedBuild) {
      package_version = "0.${package_version}-${namedBuild}"
    }

    stage("Build") {
      def buildContainerConfig = [
        dockerFile: 'Dockerfile',
        imageName: 'fastly/nghttp2',
        pushImage: false,
        cache: cache,
        additionalBuildArgs: [
          "DESTDIR=${env.WORKSPACE}",
          "PKG_VERSION=${package_version}"
        ]
      ]
      fastlyDockerBuild(script: this, containers: [buildContainerConfig], checkout: false, loggerVerbosity: 'info')
    }

    if (pushDeb) {
      stage('Push Packages to APT') {
        fastlyAptPush(script: this, path: env.WORKSPACE)
        if (slackChannel) {
          slackSend color: null, message: "Package `fst-nghttp2` version `${package_version}` uploaded.", channel: slackChannel
        }
      }
    }
    if (tagName) {
      tagName = "${tagName}-${env.BUILD_NUMBER}-${params.commit.take(7)}"
      stage('Tag Commit') {
        tagCommit(tag: tagName)
      }
    }

    if (cleanMergedRefs) {
      stage('Cleanup Merged Refs') {
        cleanupMergedBranches(script: this, masterBranch: RELEASE_BRANCH)
      }
    }
  }
}
