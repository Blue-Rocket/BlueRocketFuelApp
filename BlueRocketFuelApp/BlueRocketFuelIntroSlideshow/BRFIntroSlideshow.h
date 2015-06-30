//
//  BlueRocketFuelOnboarding.h
//  BigtimeFitness
//
//  Created by Shawn McKee on 4/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFIntroSlideshowDelegate.h"

@interface BRFIntroSlideshow : UIViewController

+ (BOOL)showInNavigationController:(UINavigationController *)controller forDelegate:(id<BRFIntroSlideshowDelegate>)delegate;

@end
