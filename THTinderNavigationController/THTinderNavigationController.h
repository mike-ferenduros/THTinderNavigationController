//
//  THTinderNavigationController.h
//  THTinderNavigationControllerExample
//
//  Created by Tanguy Hélesbeux on 11/10/2014.
//  Copyright (c) 2014 Tanguy Hélesbeux. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^THDidChangedPageBlock)(NSUInteger currentPage, NSString *title);

@interface THTinderNavigationController : UIViewController

@property (nonatomic, strong) UIView *centerContainerView;
@property (nonatomic, copy) THDidChangedPageBlock didChangedPageCompleted;

@property (nonatomic, copy) BOOL (^shouldChangePage)(NSUInteger page);

@property (nonatomic, strong) NSArray *paggedViewControllers;
@property (nonatomic, strong) NSArray *navbarItemViews;

@property (nonatomic, assign) UIEdgeInsets scrollViewInsets;
@property (nonatomic, assign) BOOL scrollEnabled;

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController;
- (instancetype)initWithRightViewController:(UIViewController *)rightViewController;
- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController;

- (NSUInteger)getCurrentPageIndex;
- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated;
- (void)reloadData;

@end
