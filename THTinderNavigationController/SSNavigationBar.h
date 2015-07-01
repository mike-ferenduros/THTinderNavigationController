//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

@import UIKit;

@class SSSlidingNavigationController;

@interface SSNavigationBar : UINavigationBar

@property (nonatomic, strong) NSArray *itemViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) CGPoint contentOffset;
@property (strong, nonatomic) SSSlidingNavigationController *slidingNavigationController;

- (void)reloadData;

@end

@protocol SSNavigationBarItem <NSObject>

@optional
- (void)updateViewWithRatio:(CGFloat)ratio;
@end
