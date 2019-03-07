# Introduction

This is a template for getting started with iOS development using GitLab and [fastlane](https://fastlane.tools/).

# Reference links

- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [Blog post: Android publishing with iOS and fastlane](https://about.gitlab.com/2019/03/06/ios-publishing-with-gitlab-and-fastlane/)

# Getting started

You'll need a working MacOS development environment with XCode 10 to use this
template. You can find instructions to get up and running on the Apple [XCode website](https://developer.apple.com/xcode/).

If you want to use GitLab CI with your own MacOS runners (a requirement since we
do not currently yet offer shared MacOS runners - follow [infrastructure#5294](https://gitlab.com/gitlab-com/gl-infra/infrastructure/issues/5294) for
updates on that front) please read through the blog post above which will walk 
you through everything you need to get up and running.

## What's contained in this project

This template contains a simple Food Tracker App based off of the [Start Developing iOS Apps (Swift) Lessons](https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/index.html). Where necessary the template has been upgraded to use Swift 4. The app displays a list of meals consisting of a name, rating, and photo. Users are able to add or edit a meal by navigating to a detail screen. The app also includes a lightweight solution for basic data persistence.
