#libGitHubIssues
Integrate GitHub Issues as a bugtracker

libGitHubIssues allows you to integrate GitHub's Issues system into your app to use as a bugtracker. It provides a single public view controller to present modally, and supports a native OAuth application flow for users to login. Existing issues can be viewed without the user needing to log in.

##Screenshots



##Installation

You can install libGitHubIssues into your application in two ways: via [CocoaPods](https://guides.cocoapods.org/using/getting-started.html), or as a dependancy in a jailbroken package.

###REQUIRED: GitHub Application

To utilise this project, you will first need to create an OAuth2 application for GitHub:

1. Upload the provided github_api_callback.php file to your server somewhere accessible.
2. Create an application [here](https://github.com/settings/developers), with the option for Authorization callback URL being the URL for said file.
  
Make a note of the client ID and secret; you will need these when using this project.

###CocoaPods

Add the following to your Podfile:
  
  pod "libGitHubIssues", "~> 0.0.1"
  
And execute:

  pod install

###Jailbroken Package

When using libGitHubIssues in a jailbroken package: 

1. On your device, download and install libGitHubIssues from Cydia.
2. Copy libGitHubIssues.dylib from /usr/lib to your development machine's theos/lib directory.
3. Copy libGitHubIssues.h from /usr/include/libGitHubIssues/ to your development machine's theos/include directory.
4. Add -lGitHubIssues to your project makefile's LDFLAGS field
5. Add a dependancy upon com.matchstic.libGitHubIssues to your project's control file.

##Usage



##Contributing

===

Released under the BSD 2-Clause license.