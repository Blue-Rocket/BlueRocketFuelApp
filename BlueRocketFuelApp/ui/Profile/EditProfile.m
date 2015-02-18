//
//  Created by Shawn McKee on 1/23/15.
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

#import "EditProfile.h"

@interface EditProfile ()
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@end

@implementation EditProfile

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameField addBottomBorderWithColor:self.tableView.separatorColor];
    [self.emailField addBottomBorderWithColor:self.tableView.separatorColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populateFields];
    [self.nameField becomeFirstResponder];
}

- (IBAction)done:(id)sender {
    
    if ([self validated]) {

        [[BRWebServiceRequest requestForAPI:@"profileEdit" parameters:@{@"user":@{
                                                                                @"name": self.nameField.text,
                                                                                }
                                                                        }]
         beginWithCompletion:^(BRWebServiceResponse *response) {
             [CurrentAppUser initializeWithDictionary:response.JSONDictionary];
             
             // the web service, however, is the authority on the user's data, so
             // update and present data from it once we have it...
             [self populateFields];
             [self.navigationController popViewControllerAnimated:YES];
             
         } failure:^(NSError *error, NSInteger code) {
             switch (code) {
                 case 422:
                     BRToDo(@"Handle already taken error.");
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

    return YES;
}

- (void)populateFields {
    self.nameField.text = CurrentAppUser.name;
    self.emailField.text = CurrentAppUser.email;
}

@end
