//
//  Created by Shawn McKee on 1/20/15.
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

#import "LoginTableViewController.h"

@interface LoginTableViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@end

@implementation LoginTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // necessary to avoid an autolayout contraint warning on the table cells...
    self.tableView.rowHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // depending on the specific design of the app being built,
    // hide or show the navigation bar...
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // bring up the keyboard and have the username field
    // ready to be entered as a convenience to the user...
    [self.usernameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // User shouldn't be allowed to return to this view once sign-in is successful,
    // so hide the back button...
    
    ((UIViewController *)segue.destinationViewController).navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                        action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Submitting Sign-In

- (IBAction)submit {
    if ([self validated]) {
        [[BRWebServiceRequest requestForAPI:@"login" parameters:@{@"user": @{
                                                                             @"email": self.usernameField.text,
                                                                             @"password": self.passwordField.text
                                                                             }
                                                                     }]
         beginWithCompletion:^(BRWebServiceResponse *response) {
             [CurrentAppUser initializeWithDictionary:response.JSONDictionary];
             [self performSegueWithIdentifier:@"main" sender:self];
         } failure:^(NSError *error, NSInteger code) {
             switch (code) {
                 case 422:
                     [[[UIAlertView alloc]
                       initWithTitle:[@"{login.error.invalid.title}" localizedString]
                       message:[@"{login.error.invalid.body}" localizedString]
                       delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
                      show];
                     break;
                     
                 default:
                     BRToDo(@"Implement error handling.");
                     break;
             }
         }];
    }
}

- (BOOL)validated {
    self.usernameField.text = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (!self.usernameField.text.length) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{login.error.username.title}" localizedString]
          message:[@"{login.error.username.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.usernameField becomeFirstResponder];
        return NO;
    }
    
    if (!self.passwordField.text.length) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{login.error.password.title}" localizedString]
          message:[@"{login.error.password.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.passwordField becomeFirstResponder];
        return NO;
    }

    return YES;
}

- (IBAction)newRegistration {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.navigationController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self performSegueWithIdentifier:@"register" sender:self];
                         [UIView animateWithDuration:0.25
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.navigationController.view.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                          }
                          ];
                     }
     ];
}


#pragma mark - UITextFieldDelegate Implementaton

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self submit];
    return YES;
}

@end
