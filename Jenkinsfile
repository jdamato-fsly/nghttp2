#!/usr/bin/env groovy

import pipeline.fastly.kubernetes.jenkins.Constants
import pipeline.fastly.github.Repo
import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException

import static pipeline.fastly.github.Repo.CommitStatus


final def BUILD_TIMEOUT = 120
final def NODELABEL = 'xenial-pbuilder'
final def RELEASE_BRANCH = 'fastly-stable'

def releaseBranches = [RELEASE_BRANCH, 'origin/' + RELEASE_BRANCH]
def cleanMergedRefs = false
def aptPushPath = null
def namedBuild = ''
def tagName = null
def slackChannel = null
def emailToSlack = [
  'jdamato@fastly.com': '@jdamato',
]

// Ignore TAG push events from GitHub, only branches built
if (params.ref.contains('refs/tags/')) {
  currentBuild.result = 'ABORTED'
  currentBuild.description = "Triggered by a TAG, ignoring ..."
  return
}

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
  aptPushPath = '.'
  cleanMergedRefs = true
  tagName = "jenkins/release"
  slackChannel = '#cpuly'
} else if (ref =~ /^.*\/jenkins$/) {
  aptPushPath = '.'
  namedBuild = ref.replaceAll("/jenkins", "").replaceAll('/', '-')
  slackChannel = emailToSlack[params.author_email]
  tagName = "jenkins/named"
} else if (ref =~ /^.*-stable$/) {
  aptPushPath = '.'
  namedBuild = ref.replaceAll("-stable", "").replaceAll('/', '-')
  slackChannel = emailToSlack[params.author_email]
  tagName = "jenkins/stable"
} else {
  namedBuild = ref.replaceAll('/', '-')
}


fastlyPipeline(script: this, buildTimeout: BUILD_TIMEOUT, slackChannel: slackChannel) {
  getNode(label: NODELABEL) {
    // Since we are using pbuilder, ensure workspace is clean
    sh "sudo rm -rf *"
      checkoutWithSubmodules scm
      def package_version = null

      stage("Build") {
        withEnv(["NAMED_BUILD=${namedBuild}"]) {
          package_version = sh (
              script: "fastly-build/get_package_version.sh",
              returnStdout: true
              ).trim()
        }
        withEnv(["PKG_VERSION=${package_version}"]) {
          sh "fastly-build/stage-1-jenkins.sh"
        }
      }

    if (aptPushPath) {
      stage('Push Packages to APT') {
        fastlyAptPush(script: this, path: aptPushPath)
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
