//
//  THTinderNavigationBar.h
//  THTinderNavigationControllerExample
//
//  Created by Tanguy Hélesbeux on 11/10/2014.
//  Copyright (c) 2014 Tanguy Hélesbeux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THTinderNavigationController.h"

@protocol THTinderNavigationBarItem <NSObject>
@optional
- (void)updateViewWithRatio:(CGFloat)ratio;
@end

@interface THTinderNavigationBar : UIToolbar

@property (nonatomic, strong) UIView *leftAccessoryView;
@property (nonatomic, strong) NSArray *itemViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) CGPoint contentOffset;
@property (strong, nonatomic) THTinderNavigationController *navigationController;
@property (copy, nonatomic) BOOL (^shouldChangePage)(NSUInteger index);

//If YES, taps are allowed to hit subviews even if they fall outside the navbar's frame
@property (nonatomic, assign) BOOL allowOutOfBoundsInteraction;

- (void)reloadData;

@end

