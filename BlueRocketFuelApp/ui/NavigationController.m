//
//  Created by Shawn McKee on 1/22/15.
//
//  Copyright (c) 2015 Blue Rocket, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <BlueRocketFuelCore/BlueRocketFuelCore.h>

#import "NavigationController.h"
#import "OptionsTray.h"

static NavigationController *sharedInstance;

@implementation NavigationController

+ (NavigationController *)sharedInstance {
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sharedInstance = self;
}

- (UIBarButtonItem *)optionsTrayBarButtonForController:(UIViewController *)vc {
    
    OptionsTray *optionsTrayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"optionsTray"];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                  handler:^(id sender) {
                                                                                      [optionsTrayViewController showForViewController:vc];
                                                                                  }];

    return menuButton;
}

- (void)logOut {
    //[CurrentAppUser clear];
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"startupViewController"]];
                         [UIView animateWithDuration:0.25
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.view.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                          }
                          ];
                     }
     ];
}

@end
