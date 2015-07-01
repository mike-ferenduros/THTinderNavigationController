//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

@import UIKit;

#import "SSNavigationBar.h"

@interface SSNavigationBarItem : UIView <SSNavigationBarItem>

- (instancetype)initWithImage:(UIImage *)image activeColor:(UIColor *)activeColor inactiveColor:(UIColor *)inactiveColor;
- (instancetype)initWithView:(UIView *)view activeColor:(UIColor *)activeColor inactiveColor:(UIColor *)inactiveColor;

@end
