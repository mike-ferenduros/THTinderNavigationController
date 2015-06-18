//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

#import <UIKit/UIKit.h>
#import "THTinderNavigationBar.h"

@interface SSNavigationBarItem : UIView <THTinderNavigationBarItem>

- (instancetype)initWithImage:(UIImage *)image activeColor:(UIColor *)activeColor inactiveColor:(UIColor *)inactiveColor;
- (instancetype)initWithView:(UIView *)view activeColor:(UIColor *)activeColor inactiveColor:(UIColor *)inactiveColor;

@end
