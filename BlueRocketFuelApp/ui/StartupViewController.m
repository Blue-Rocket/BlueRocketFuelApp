//
//  Created by Shawn McKee on 1/15/15.
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

#import <BlueRocketFuel/BlueRocketFuel.h>

#import "StartupViewController.h"

@interface StartupViewController ()

@end

@implementation StartupViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // open the apporpriate view based on whither or not
    // the user has registered and logged in...
    
    if (CurrentAppUser.newUser) {
        [self performSegueWithIdentifier:@"register" sender:self];
    }
    else if (!CurrentAppUser.authenticated) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"main" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // this startup view is implemented as a launch point to determine
    // what view to show first when the app first runs, and users
    // should never be able to return to it from any view we go to
    // from here, so sure we hide the back button for any
    // destination view controller we are going to...
    
    ((UIViewController *)segue.destinationViewController).navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

@end
