//
//  OpsViewController.m
//  Ingress
//
//  Created by Alex Studnička on 16.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "OpsViewController.h"
#import "TTUIScrollViewSlidingPages.h"

@implementation OpsViewController {
	CADisplayLink *_displayLink;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	self.scoreViewController = [storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];

	TTScrollSlidingPagesController *slider = [TTScrollSlidingPagesController new];
	slider.titleScrollerHeight = 64;
	slider.disableTitleScrollerShadow = YES;
	slider.disableUIPageControl = YES;
	slider.zoomOutAnimationDisabled = YES;
	slider.dataSource = self;
//	slider.scrollViewDelegate = self;
	slider.view.backgroundColor = [UIColor colorWithRed:16./255. green:32./255. blue:34./255. alpha:1.0];

	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-20;
	slider.view.frame = CGRectMake(0, 20, viewWidth, viewHeight);

	[self.view addSubview:slider.view];
	[self.view sendSubviewToBack:slider.view];
	[self addChildViewController:slider];

//	UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(10)}];
//
//	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
//	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-20;
//	pageViewController.view.frame = CGRectMake(0, 20, viewWidth, viewHeight);
//
//	pageViewController.dataSource = self;
//	pageViewController.delegate = self;
//
//	[self.view addSubview:pageViewController.view];
//	[self.view sendSubviewToBack:pageViewController.view];
//	[self addChildViewController:pageViewController];
//
//	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//
//	[pageViewController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"ResourcesViewController"]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
//		NSLog(@"setViewControllers completion %d", finished);
//	}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)back {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }

	if ([self.delegate respondsToSelector:@selector(willDismissOpsViewController:)]) {
		[self.delegate willDismissOpsViewController:self];
	}

	[self dismissViewControllerAnimated:YES completion:^{
		if ([self.delegate respondsToSelector:@selector(didDismissOpsViewController:)]) {
			[self.delegate didDismissOpsViewController:self];
		}
	}];
}

#pragma mark - UIPageViewControllerDataSource & UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

	if ([viewController isKindOfClass:NSClassFromString(@"PortalKeysViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"ResourcesViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"MediaItemsViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"PortalKeysViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"ScoreViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"MediaItemsViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"MissionsViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"RecruitViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"MissionsViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"DeviceViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"RecruitViewController"];
	}

	return nil;

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

	if ([viewController isKindOfClass:NSClassFromString(@"ResourcesViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"PortalKeysViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"PortalKeysViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"MediaItemsViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"MediaItemsViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"ScoreViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"MissionsViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"MissionsViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"RecruitViewController"];
	} else if ([viewController isKindOfClass:NSClassFromString(@"RecruitViewController")]) {
		return [storyboard instantiateViewControllerWithIdentifier:@"DeviceViewController"];
	}

	return nil;
	
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self startDisplayLinkIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self stopDisplayLink];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self stopDisplayLink];
}

#pragma mark - Display Link

- (void)startDisplayLinkIfNeeded {
	if (!_displayLink) {
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(draw)];
		[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	}
}

- (void)stopDisplayLink {
	[_displayLink invalidate];
	_displayLink = nil;
}

- (void)draw {
	GLViewController *glVC = (GLViewController *)self.scoreViewController.glViewController;
	[glVC performSelector:@selector(update) withObject:nil];
	[glVC.view performSelector:@selector(display) withObject:nil];
}

#pragma mark - TTSlidingPagesDataSource

- (int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source {
    return 7;
}

- (TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
    UIViewController *viewController;
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

	switch (index) {
		case 0:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"ResourcesViewController"];
			break;
		case 1:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"PortalKeysViewController"];
			break;
		case 2:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"MediaItemsViewController"];
			break;
		case 3:
			viewController = self.scoreViewController; //[storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];
			break;
		case 4:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"MissionsViewController"];
			break;
		case 5:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"RecruitViewController"];
			break;
		case 6:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceViewController"];
			break;
	}

    return [[TTSlidingPage alloc] initWithContentViewController:viewController];
}

- (TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index{
    TTSlidingPageTitle *title;
	switch (index) {
		case 0:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Resources"];
			break;
		case 1:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Portal Keys"];
			break;
		case 2:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Media"];
			break;
		case 3:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Intel"];
			break;
		case 4:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Missions"];
			break;
		case 5:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Recruit"];
			break;
		case 6:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Device"];
			break;
	}
    return title;
}

@end
