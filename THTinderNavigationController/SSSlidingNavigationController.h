//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

@import UIKit;

@class SSNavigationBarItem;
@class SSNavigationBar;

@protocol SSSlidingNavigationControllerDelegate

@required
- (UIViewController *)viewControllerAtIndex:(NSInteger)index;
@end

@interface SSSlidingNavigationController : UIPageViewController

@property (nonatomic, strong) SSNavigationBar *paggingNavbar;
@property (nonatomic) NSUInteger actualPageIndex;
@property (nonatomic) NSUInteger slidingStarted;

@property (nonatomic, assign) id <SSSlidingNavigationControllerDelegate> viewsDelegate;

- (NSInteger)currentPageIndex;
- (void)setCurrentPage:(NSUInteger)newPageIndex animated:(BOOL)animated;
- (void)setNavigationBarItemViews:(NSArray *)navbarItemViews;

@end
