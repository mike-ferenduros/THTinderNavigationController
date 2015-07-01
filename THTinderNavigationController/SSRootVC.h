//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

@import UIKit;

#import "SSSlidingNavigationController.h"

@protocol SSRootVCDelegate

@required
- (UIViewController *)viewControllerAtIndex:(NSInteger)index;
@end

@interface SSRootVC : UIViewController <SSSlidingNavigationControllerDelegate>

@property (nonatomic, assign) id <SSRootVCDelegate> viewsDelegate;

- (void)setInitialViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)setNavigationBarItems:(NSArray *)navBarItems;

@end