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

#import "Profile.h"
#import "NavigationController.h"

@interface Profile ()
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@end

@implementation Profile

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [AppNavigationController optionsTrayBarButtonForController:self];
    
    // display any local profile data we have first, before we
    // try to go out to the web service and get the data stored there...
    [self populateFields];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[BRWebServiceRequest requestForAPI:@"profileView"]
     beginWithCompletion:^(BRWebServiceResponse *response) {
         [CurrentAppUser initializeWithDictionary:response.JSONDictionary];
         
         // the web service, however, is the authority on the user's data, so
         // update and present data from it once we have it...
         [self populateFields];
         
     } failure:^(NSError *error, NSInteger code) {
         switch (code) {
             default:
                 BRToDo(@"Implement error handling.");
                 break;
         }
     }];

}

- (void)populateFields {
    self.nameLabel.text = CurrentAppUser.name;
    self.emailLabel.text = CurrentAppUser.email;
}

- (IBAction)edit:(id)sender {
    [self performSegueWithIdentifier:@"editProfile" sender:sender];
}

@end
