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
#import <BRLocalize/Core.h>

#import "LoginTableViewController.h"
#import "UIColor+App.h"
#import "UIButton+App.h"
#import "NavigationController.h"
#import "AlertController.h"

@interface LoginTableViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@end

@implementation LoginTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor loginBackgroundColor];
    
    // necessary to avoid an autolayout contraint warning on the table cells...
    self.tableView.rowHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // depending on the specific design of the app being built,
    // hide or show the navigation bar...
    //[self.navigationController setNavigationBarHidden:YES];
    [self.submitButton addButtonShape];
    
    UIColor *fieldColor = [UIColor loginFieldColor];
    UIColor *placeholderColor = [[UIColor loginFieldColor] colorWithAlphaComponent:0.25];
    UIColor *separatorColor = [[UIColor loginFieldColor] colorWithAlphaComponent:0.25];
    
    
    self.usernameField.textColor = fieldColor;
    [self.usernameField setPlaceholderColor:placeholderColor];
    [self.usernameField addBottomBorderWithColor:separatorColor];
    
    self.passwordField.textColor = fieldColor;
    [self.passwordField setPlaceholderColor:placeholderColor];
    [self.passwordField addBottomBorderWithColor:separatorColor];
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
    if (![segue.identifier isEqualToString:@"register"]) {
        ((UIViewController *)segue.destinationViewController).navigationItem.hidesBackButton = YES;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                        action:nil];
    }
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
             //[CurrentAppUser initializeWithDictionary:response.JSONDictionary];
             [self performSegueWithIdentifier:@"main" sender:self];
         } failure:^(NSError *error, NSInteger code) {
             switch (code) {
                 case 422:{
                     AlertController *alert = [AlertController alertControllerWithTitle:[@"{login.error.invalid.title}" localizedString]
                                               
                                                                                message:[@"{login.error.invalid.body}" localizedString]
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                     [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                     }]];
                     [AppNavigationController presentViewController:alert animated:YES completion:nil];
                     break;}
                     
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
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{login.error.username.title}" localizedString]
                                                                   message:[@"{login.error.username.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.usernameField becomeFirstResponder];
        return NO;
    }
    
    if (!self.passwordField.text.length) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{login.error.password.title}" localizedString]
                                                                   message:[@"{login.error.password.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.usernameField becomeFirstResponder];

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
                         self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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

- (IBAction)resetPassword:(id)sender {
    AlertController *alert = [AlertController alertControllerWithTitle:@"Reset Password" message:@"Please enter the email address\nyou registered with:" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    
    [alert addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields[0];
        BRInfoLog(@"email: %@", textField.text);
        [self resetPasswordForEmail:textField.text];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetPasswordForEmail:(NSString *)email {
    [[BRWebServiceRequest requestForAPI:@"resetPassword" parameters:@{@"email": email
                                                                      }]
     beginWithCompletion:^(BRWebServiceResponse *response) {
         AlertController *alert = [AlertController alertControllerWithTitle:[@"Request Sent" localizedString]
                                                                    message:[@"Check your email for instructions on how to set a new password." localizedString]
                                                             preferredStyle:UIAlertControllerStyleAlert];
         [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
         }]];
         [AppNavigationController presentViewController:alert animated:YES completion:nil];
     } failure:^(NSError *error, NSInteger code) {
         switch (code) {
             case 422:{
                 AlertController *alert = [AlertController alertControllerWithTitle:[@"{login.error.invalid.title}" localizedString]
                                           
                                                                            message:[@"{login.error.invalid.body}" localizedString]
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                 [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                 }]];
                 [AppNavigationController presentViewController:alert animated:YES completion:nil];
                 break;}
                 
             default:
                 BRToDo(@"Implement error handling.");
                 break;
         }
     }];
    
}

#pragma mark - UITextFieldDelegate Implementaton

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self submit];
    return YES;
}

@end
