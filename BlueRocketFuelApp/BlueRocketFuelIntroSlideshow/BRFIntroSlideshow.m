//
//  BlueRocketFuelOnboarding.m
//  BigtimeFitness
//
//  Created by Shawn McKee on 4/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <BlueRocketFuelCore/BlueRocketFuelCore.h>
#import <BRLocalize/Core.h>
#import "BRFIntroSlideshow.h"
#import "UIButton+App.h"

@interface BRFIntroSlideshow () <UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *skipButton;
@property (nonatomic, weak) id<BRFIntroSlideshowDelegate> slideShowDelegate;
@end

@implementation BRFIntroSlideshow

+ (BOOL)showInNavigationController:(UINavigationController *)controller forDelegate:(id<BRFIntroSlideshowDelegate>)delegate {
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BRIntroSlideshowHasBeenShown"]) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"BRIntroSlideshowHasBeenShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    BRFIntroSlideshow *vc = [sb instantiateInitialViewController];
    vc.slideShowDelegate = delegate;
    [controller pushViewController:vc animated:YES];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.edgesForExtendedLayout = UIRectEdgeNone;

    NSArray *list = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"onboarding" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSError *error;
    if (data) list = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves) error:&error];
    
    self.scrollView.pagingEnabled = YES;
    
    CGRect r = self.scrollView.bounds;
    NSInteger count = 0;
    for (NSString *vcIdentifier in list) {
        @try {
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
            if (vc) {
                vc.view.frame = r;
                [self.scrollView addSubview:vc.view];
                r.origin.x += r.size.width;
                count++;
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    CGSize size = r.size;
    size.width = r.origin.x;
    self.scrollView.contentSize = size;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = count;
    self.pageControl.currentPage = 0;
    
    [self.skipButton addButtonShape];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)skip {
    if ([self.slideShowDelegate respondsToSelector:@selector(introSlideShowDidEnd)]) {
        [UIView animateWithDuration:0.35
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.navigationController.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.slideShowDelegate introSlideShowDidEnd];
                             [UIView animateWithDuration:0.35
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  self.navigationController.view.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                              }
                              ];
                         }
         ];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    NSInteger page = rintf(self.scrollView.contentOffset.x / pageWidth);
    self.pageControl.currentPage = page;
    
    
    if (self.pageControl.currentPage == self.pageControl.numberOfPages-1) {
        [self.skipButton setTitle:[@"{button.done}" localizedString] forState:UIControlStateNormal];
        [self.skipButton setTitle:[@"{button.done}" localizedString] forState:UIControlStateHighlighted];
    }
    else {
        [self.skipButton setTitle:[@"{button.skip}" localizedString] forState:UIControlStateNormal];
        [self.skipButton setTitle:[@"{button.skip}" localizedString] forState:UIControlStateHighlighted];
    }
}


@end
