//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

#import "SSSlidingNavigationController.h"
#import "SSPageViewContentProtocol.h"
#import "SSNavigationBar.h"

@interface SSSlidingNavigationController () <UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@end

@implementation SSSlidingNavigationController

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

    self.delegate = self;
    self.dataSource = self;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *) v).delegate = self;
        }
    }

    [self reloadData];
}

#pragma mark - Properties

- (SSNavigationBar *)paggingNavbar {
    if (!_paggingNavbar) {
        _paggingNavbar = [[SSNavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
        _paggingNavbar.backgroundColor = [UIColor clearColor];
        _paggingNavbar.slidingNavigationController = self;
        [self.view addSubview:_paggingNavbar];
    }
    return _paggingNavbar;
}

- (NSInteger)currentPageIndex {
    UIViewController *currentViewController = [self currentViewController];
    if (currentViewController && [currentViewController conformsToProtocol:@protocol(SSPageViewContentProtocol)]) {
        return [((id <SSPageViewContentProtocol>) currentViewController) pageIndex];
    }

    return -1;
}

- (UIViewController *)currentViewController {
    return [self.viewControllers firstObject];
}

#pragma mark - Helpers

- (void)setCurrentPage:(NSUInteger)newPageIndex animated:(BOOL)animated {
    NSInteger currentPageIndex = [self currentPageIndex];
    if (newPageIndex == currentPageIndex) {
        return;
    }

    UIViewController *newViewController = nil;
    UIPageViewControllerNavigationDirection direction;
    if (newPageIndex > currentPageIndex) {
        newViewController = [self.dataSource pageViewController:self viewControllerAfterViewController:[self currentViewController]];
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        newViewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:[self currentViewController]];
        direction = UIPageViewControllerNavigationDirectionReverse;
    }

    if (newViewController) {
        __weak __typeof(self) weakSelf = self;
        [self setViewControllers:@[newViewController] direction:direction animated:animated completion:^(BOOL finished) {
            weakSelf.actualPageIndex = newPageIndex;
        }];
    }
}

- (void)setNavigationBarItemViews:(NSArray *)navbarItemViews {
    self.paggingNavbar.itemViews = navbarItemViews;
    [self reloadData];

    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [self scrollViewDidScroll:(UIScrollView *) v];
        }
    }
}

- (void)reloadData {
    [self.paggingNavbar reloadData];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    return [self.viewsDelegate viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate & UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (!viewController) {
        return nil;
    }

    NSAssert([viewController conformsToProtocol:@protocol(SSPageViewContentProtocol)], @"Page View must to implement SSPageViewContentProtocol");
    NSInteger index = ((id <SSPageViewContentProtocol>) viewController).pageIndex;

    if ((index < 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (!viewController) {
        return nil;
    }

    NSAssert([viewController conformsToProtocol:@protocol(SSPageViewContentProtocol)], @"Page View must to implement SSPageViewContentProtocol");
    NSInteger index = ((id <SSPageViewContentProtocol>) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.slidingStarted = 1;
    self.actualPageIndex = (NSUInteger) [self currentPageIndex];
    if (!finished) {
        return;
    }

    UIViewController *newViewController = [pageViewController.viewControllers firstObject];
    if (newViewController && [newViewController conformsToProtocol:@protocol(SSPageViewContentProtocol)]) {
        [self.paggingNavbar setCurrentPage:(NSUInteger) [((id <SSPageViewContentProtocol>) newViewController) pageIndex]];
        [self.paggingNavbar reloadData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint newoffset = CGPointMake(scrollView.contentOffset.x + self.actualPageIndex * CGRectGetWidth(self.view.frame) - self.slidingStarted * CGRectGetWidth(self.view.frame), 0.0f);
    if (newoffset.x >= 0 && newoffset.x <= (self.actualPageIndex + 1) * CGRectGetWidth(self.view.frame)) {
        self.paggingNavbar.contentOffset = newoffset;
    }
}

@end
