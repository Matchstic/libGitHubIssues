#libGitHubIssues
Integrate GitHub Issues as a bugtracker

Integrate GitHub's Issues system into your app to use as a bugtracker. A single public view controller is provided to present modally, and supports a native OAuth application flow for users to login. Existing issues can be viewed without the user needing to log in.

##Screenshots

![Issues Overview](/Screenshots/screenshot1.png?raw=true "Issues Overview")
![Issue Detail](/Screenshots/screenshot2.png?raw=true "Issue Detail")
![Login UI](/Screenshots/screenshot3.png?raw=true "Login UI")
![Comment Composer](/Screenshots/screenshot4.png?raw=true "Comment Composer")
![Issue Composer](/Screenshots/screenshot5.png?raw=true "Issue COmposer")

##Installation

You can install libGitHubIssues into your application in two ways: via [CocoaPods](https://guides.cocoapods.org/using/getting-started.html), or as a dependancy in a jailbroken package.

###REQUIRED: GitHub Application

To utilise this project, you will first need to create an OAuth2 application for GitHub [here](https://github.com/settings/developers); fill in the homepage URL with your website, as it won't be needed for functionality.
  
Make a note of the client ID and secret; you will need these when using this project.

###CocoaPods

Add

  pod "libGitHubIssues", "~> 0.0.1"

to your Podfile.

###Jailbroken Package

When using libGitHubIssues in a jailbroken package: 

1. On your device, download and install libGitHubIssues from Cydia.
2. Copy libGitHubIssues.dylib from /usr/lib to your development machine's theos/lib directory.
3. Copy libGitHubIssues.h from /usr/include/libGitHubIssues/ to your development machine's theos/include directory.
4. Add -lGitHubIssues to your project makefile's LDFLAGS field
5. Add a dependancy upon com.matchstic.libGitHubIssues to your project's control file.

##Usage

    \#import <libGitHubIssues.h>

    ...

    GIRootViewController *rootModal = [[GIRootViewController alloc] init];

    [GIRootViewController registerClientID:@"<client_id>" andSecret:@"<client_secret>"];
    [GIRootViewController registerCurrentRepositoryName:@"Xen" andOwner:@"Matchstic"];

    [self presentViewController:rootModal animated:YES completion:nil];

##Contributing

To work on this project, clone or fork it:

    $ git clone https://github.com/Matchstic/libGitHubIssues.git

update CocoaPods:

    $ pod update

and open libGitHubIssues.xcworkspace.

To build the libGitHubIssues-(Jailbreak) target you will need iOSOpenDev.

===

Released under the BSD 2-Clause license.
