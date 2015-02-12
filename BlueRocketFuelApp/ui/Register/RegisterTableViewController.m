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

#import <BlueRocketFuel/BlueRocketFuel.h>

#import "RegisterTableViewController.h"

@interface RegisterTableViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordField;
@end

@implementation RegisterTableViewController

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
    
    // uncomment this if you would like to bring up the keyboard and have the name field
    // ready to be entered as a convenience to the user. we're not doing
    // that by default so that the full registration form can be seen by the user first
    // (i.e. not have the keyboard obscure the form right away)
    // so the user can see how many fields there are to enter.
    // [self.nameField becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // User shouldn't be allowed to return to this view once registration is successful,
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


#pragma mark - Submitting Registration

- (IBAction)submit {
    if ([self validated]) {
        [[BRWebServiceRequest requestForAPI:@"register" parameters:@{@"user": @{
                                                                             @"email": self.emailField.text,
                                                                             @"name": self.nameField.text,
                                                                             @"password": self.passwordField.text,
                                                                             @"password_confirmation": self.confirmPasswordField.text
                                                                             }
                                                                     }]
         beginWithCompletion:^(BRWebServiceResponse *response) {
             BRInfoLog(@":::: %@",response.JSONDictionary);
             [CurrentAppUser initializeWithDictionary:response.JSONDictionary];
             [self performSegueWithIdentifier:@"main" sender:self];
         } failure:^(NSError *error, NSInteger code) {
             switch (code) {
                 case 422:
                     [[[UIAlertView alloc]
                       initWithTitle:[@"{register.error.invalid.title}" localizedString]
                       message:[@"{register.error.invalid.body}" localizedString]
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
    
    self.nameField.text = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.emailField.text = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!self.nameField.text.length) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{register.error.name.title}" localizedString]
          message:[@"{register.error.name.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.nameField becomeFirstResponder];
        return NO;
    }
    
    if (!self.emailField.text.length) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{register.error.email.missing.title}" localizedString]
          message:[@"{register.error.email.missing.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.emailField becomeFirstResponder];
        return NO;
    }
    
    if (![self.emailField.text isValidEmailFormat]) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{register.error.email.format.title}" localizedString]
          message:[@"{register.error.email.format.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.emailField becomeFirstResponder];
        return NO;
    }
    
    if (!self.passwordField.text.length) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{register.error.password.missing.title}" localizedString]
          message:[@"{register.error.password.missing.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    
    if (!self.confirmPasswordField.text.length) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{register.error.password.confirm.title}" localizedString]
          message:[@"{register.error.password.confirm.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.confirmPasswordField becomeFirstResponder];
        return NO;
    }
    
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        [[[UIAlertView alloc]
          initWithTitle:[@"{register.error.password.match.title}" localizedString]
          message:[@"{register.error.password.match.body}" localizedString]
          delegate:nil cancelButtonTitle:[@"{button.ok}" localizedString] otherButtonTitles:nil]
         show];
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)login {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.navigationController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self performSegueWithIdentifier:@"login" sender:self];
                         [UIView animateWithDuration:0.25
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
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
