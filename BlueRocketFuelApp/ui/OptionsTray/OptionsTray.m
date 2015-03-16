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

#import "OptionsTray.h"
#import "OptionsTrayCell.h"
#import "AppDelegate.h"
#import "NavigationController.h"

@interface OptionsTray ()

@property(nonatomic, strong) IBOutlet UITableView *optionsTable;
@property(nonatomic, strong) NSArray *optionsArray;

@end

@implementation OptionsTray

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.optionsTable.rowHeight = 44;
    self.optionsArray = appDelegate.config[@"optionsTray"];
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionsTrayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionsTrayCell"];
    
    cell.optionLabel.text = self.optionsArray[indexPath.row][@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *optionProperties = self.optionsArray[indexPath.row];
    
    UIViewController *vc = nil;
    
    if ([optionProperties[@"resourceType"] isEqualToString:@"storyboard"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:optionProperties[@"resourceName"] bundle:nil];
        vc = [sb instantiateInitialViewController];
        
        // If the storyboard has a nav controller as the initial controller, then grab its root vc instead.
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).viewControllers[0];
        }
        
    } else if ([optionProperties[@"resourceType"] isEqualToString:@"xib"]) {
        NSString *nibName = optionProperties[@"resourceName"];
        vc = [[NSClassFromString(nibName) alloc] initWithNibName:nibName bundle:nil];

    } else if ([optionProperties[@"resourceType"] isEqualToString:@"class"]) {
        NSString *className = optionProperties[@"resourceName"];
        vc = [[NSClassFromString(className) alloc] init];
    }
    
    if (vc) {
        [self hideWithCompletion:^{
            AppNavigationController.viewControllers = [NSArray arrayWithObject:vc];
        }];
    }
}

#pragma mark - Custom Actions

// Add all custom IBAction handlers for the options tray here. Controller UI is configured in the main storyboard...

// Overridding
- (void)hide {
    [self hideWithCompletion:^{
        // Call this to refresh the reference to OptionsTray within the menu button in the case the user dismisses tray without choosing a different vc.
        [AppNavigationController.viewControllers[0] viewWillAppear:NO];
    }];
}

- (IBAction)logOut {
    [self hideWithCompletion:^{
        [AppNavigationController logOut];
    }];
}


@end
