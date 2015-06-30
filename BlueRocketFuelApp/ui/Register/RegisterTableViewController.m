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

#import "RegisterTableViewController.h"
#import "UIColor+App.h"
#import "UIButton+App.h"
#import "EditProfile.h"
#import "Profile.h"
#import "NavigationController.h"
#import "AlertController.h"

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
    
    self.view.backgroundColor = [UIColor registrationBackgroundColor];
    
    // necessary to avoid an autolayout contraint warning on the table cells...
    self.tableView.rowHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // depending on the specific design of the app being built,
    // hide or show the navigation bar...
    //[self.navigationController setNavigationBarHidden:YES];
    
    UIColor *fieldColor = [UIColor registrationFieldColor];
    UIColor *placeholderColor = [[UIColor registrationFieldColor] colorWithAlphaComponent:0.25];
    UIColor *separatorColor = [[UIColor registrationFieldColor] colorWithAlphaComponent:0.25];
    
    self.nameField.textColor = fieldColor;
    [self.nameField setPlaceholderColor:placeholderColor];
    [self.nameField addBottomBorderWithColor:separatorColor];
    
    self.emailField.textColor = fieldColor;
    [self.emailField setPlaceholderColor:placeholderColor];
    [self.emailField addBottomBorderWithColor:separatorColor];
    
    self.passwordField.textColor = fieldColor;
    [self.passwordField setPlaceholderColor:placeholderColor];
    [self.passwordField addBottomBorderWithColor:separatorColor];
    
    self.confirmPasswordField.textColor = fieldColor;
    [self.confirmPasswordField setPlaceholderColor:placeholderColor];
    [self.confirmPasswordField addBottomBorderWithColor:separatorColor];
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
    if ([segue.identifier isEqualToString:@"profile"]) {
        EditProfile *vc = (EditProfile *)segue.destinationViewController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Submitting Registration

static const NSString *emailAddressError = @"email";
static const NSString *passwordError = @"password";
static const NSString *usernameError = @"username";

static const NSInteger registrationErrorCode = 422;

- (IBAction)submit {
    if ([self validated]) {
        [[BRWebServiceRequest requestForAPI:@"register" parameters:@{@"user": @{
                                                                             @"email": self.emailField.text,
                                                                             @"username": self.nameField.text,
                                                                             @"password": self.passwordField.text,
                                                                             @"password_confirmation": self.confirmPasswordField.text
                                                                             }
                                                                     }]
         beginWithCompletion:^(BRWebServiceResponse *response) {
             [CurrentAppUser initializeWithDictionary:response.JSONDictionary];
             [self performSegueWithIdentifier:@"profile" sender:self];
         } failure:^(NSError *error, NSInteger code) {
             switch (code) {
                 case registrationErrorCode: {
                     NSDictionary *userInfo = error.userInfo;
                     if ([userInfo objectForKey:emailAddressError]) {
                         NSArray *messages = [userInfo objectForKey:emailAddressError];
                         NSString *messageText = [self buildMessageErrorTextWithTitle:@"Email Address"
                                                                          andMessages:messages];
                         [self raiseAlertOnMainThreadWithTitle:@"Invalid Email Address"
                                                    andMessage:messageText];
                     } else if ([userInfo objectForKey:passwordError]) {
                         NSArray *messages = [userInfo objectForKey:passwordError];
                         NSString *messageText = [self buildMessageErrorTextWithTitle:@"Password"
                                                                          andMessages:messages];
                         [self raiseAlertOnMainThreadWithTitle:@"Invalid Password"
                                                    andMessage:messageText];
                     } else if ([userInfo objectForKey:usernameError]) {
                         NSArray *messages = [userInfo objectForKey:usernameError];
                         NSString *messageText = [self buildMessageErrorTextWithTitle:@"Username"
                                                                          andMessages:messages];
                         [self raiseAlertOnMainThreadWithTitle:@"Username already taken"
                                                    andMessage:messageText];

                     }
                     else {
                         [self raiseAlertOnMainThreadWithTitle:@"Error Occurred"
                                                    andMessage:@"Please check your data and try again."];
                     }
                     break;
                 }
                 default:
                     [self raiseAlertOnMainThreadWithTitle:@"Error Occurred"
                                                andMessage:@"Please check your data and try again."];
                     break;
             }
         }];
    }
}
-(NSString*)buildMessageErrorTextWithTitle:(NSString*)title andMessages:(NSArray*)messages
{
    NSString *messageText = @"";
    if (messages) {
        messageText = title;
        for (NSString *errorMessage in messages) {
            messageText = [NSString stringWithFormat:@"%@ %@\n",messageText, errorMessage];
        }
    }
    return messageText;
}

-(void)raiseAlertOnMainThreadWithTitle:(NSString*)title andMessage:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AlertController *alert = [AlertController alertControllerWithTitle:title
                                  
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
    });
}

- (BOOL)validated {
    
    self.nameField.text = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.emailField.text = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!self.nameField.text.length) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{register.error.username.title}" localizedString]
                                                                   message:[@"{register.error.username.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.nameField becomeFirstResponder];
        return NO;
    }
    
    if (!self.emailField.text.length) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{register.error.email.missing.title}" localizedString]
                                                                   message:[@"{register.error.email.missing.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.emailField becomeFirstResponder];
        return NO;
    }
    
    if (![self.emailField.text isValidEmailFormat]) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{register.error.email.format.title}" localizedString]
                                                                   message:[@"{register.error.email.format.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.emailField becomeFirstResponder];
        return NO;
    }
    
    if (!self.passwordField.text.length) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{register.error.password.missing.title}" localizedString]
                                                                   message:[@"{register.error.password.missing.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    
    if (!self.confirmPasswordField.text.length) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{register.error.password.confirm.title}" localizedString]
                                                                   message:[@"{register.error.password.confirm.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
        [self.confirmPasswordField becomeFirstResponder];
        return NO;
    }
    
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        AlertController *alert = [AlertController alertControllerWithTitle:[@"{register.error.password.match.title}" localizedString]
                                                                   message:[@"{register.error.password.match.body}" localizedString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[@"{button.ok}" localizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [AppNavigationController presentViewController:alert animated:YES completion:nil];
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
