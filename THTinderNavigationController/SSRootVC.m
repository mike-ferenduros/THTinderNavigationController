//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

#import "SSRootVC.h"

@interface SSRootVC ()

@property (nonatomic, strong) SSSlidingNavigationController *slidingNavigationController;
@end

@implementation SSRootVC

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

#pragma mark - System Defined

- (void)viewDidLoad {
    [super viewDidLoad];

    self.slidingNavigationController = [[SSSlidingNavigationController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                              options:nil];
    self.slidingNavigationController.viewsDelegate = self;

    [self addChildViewController:self.slidingNavigationController];
    [self.view addSubview:self.slidingNavigationController.view];
    [self.slidingNavigationController didMoveToParentViewController:self];
}

#pragma mark - View Helpers

- (void)setInitialViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    [self.slidingNavigationController setCurrentPage:index animated:NO];
    self.slidingNavigationController.actualPageIndex = index;
    self.slidingNavigationController.slidingStarted = 1;
    [self.slidingNavigationController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)setNavigationBarItems:(NSArray *)navBarItems {
    [self.slidingNavigationController setNavigationBarItemViews:navBarItems];
}

#pragma mark - SSRootVCDelegate

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    return [self.viewsDelegate viewControllerAtIndex:index];
}

@end