//
//  THTinderNavigationController.m
//  THTinderNavigationControllerExample
//
//  Created by Tanguy Hélesbeux on 11/10/2014.
//  Copyright (c) 2014 Tanguy Hélesbeux. All rights reserved.
//

#import "THTinderNavigationController.h"
#import "THTinderNavigationBar.h"

typedef NS_ENUM(NSInteger, THSlideType) {
    THSlideTypeLeft = 0,
    THSlideTypeRight = 1,
};

@interface THTinderNavigationController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *paggingScrollView;

@property (nonatomic, strong, readwrite) THTinderNavigationBar *paggingNavbar;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong) UIViewController *leftViewController;

@property (nonatomic, strong) UIViewController *rightViewController;

@end

@implementation THTinderNavigationController

#pragma mark - DataSource

- (NSUInteger)getCurrentPageIndex {
    return self.currentPage;
}

- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated {
    [self view];
    self.paggingNavbar.currentPage = currentPage;
    if (animated) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.currentPage = currentPage;
        });
    } else {
        self.currentPage = currentPage;
    }

    CGFloat pageWidth = CGRectGetWidth(self.paggingScrollView.frame);

    [self.paggingScrollView setContentOffset:CGPointMake(currentPage * pageWidth, self.paggingScrollView.contentOffset.y) animated:animated];

}

- (void)reloadData {
    if (!self.paggedViewControllers.count) {
        return;
    }

    [self.paggingScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [self.paggedViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.paggingScrollView addSubview:viewController.view];
        [self.paggingScrollView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.paggingScrollView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        if (idx == 0) {
            [self.paggingScrollView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        } else {
            UIViewController *prev = self.paggedViewControllers[idx-1];
            [self.paggingScrollView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:prev.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
        if (idx == self.paggedViewControllers.count - 1) {
            [self.paggingScrollView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
        [self.centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.centerContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.centerContainerView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];

        [self addChildViewController:viewController];
    }];

    self.paggingNavbar.itemViews = self.navbarItemViews;
    [self.paggingNavbar reloadData];

    [self setupScrollToTop];

    [self callBackChangedPage];
}

#pragma mark - Propertys

- (void)setScrollViewInsets:(UIEdgeInsets)scrollViewInsets {
    self.paggingScrollView.contentInset = scrollViewInsets;
}

- (UIEdgeInsets)scrollViewInsets {
    return self.paggingScrollView.contentInset;
}

- (void)setShouldChangePage:(BOOL (^)(NSUInteger))shouldChangePage {
    self.paggingNavbar.shouldChangePage = shouldChangePage;
}

- (BOOL (^)(NSUInteger))shouldChangePage {
    return self.paggingNavbar.shouldChangePage;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.paggingScrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
    return self.paggingScrollView.scrollEnabled;
}

- (UIView *)centerContainerView {
    if (!_centerContainerView) {
        _centerContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _centerContainerView.backgroundColor = [UIColor whiteColor];

        [_centerContainerView addSubview:self.paggingScrollView];
        self.paggingScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [_centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_centerContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [_centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_centerContainerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [_centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_centerContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [_centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_centerContainerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.paggingScrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.paggingScrollView.panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerHandle:)];
    }
    return _centerContainerView;
}

- (UIScrollView *)paggingScrollView {
    if (!_paggingScrollView) {
        _paggingScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _paggingScrollView.bounces = NO;
        _paggingScrollView.pagingEnabled = YES;
        [_paggingScrollView setScrollsToTop:NO];
        _paggingScrollView.delegate = self;
        _paggingScrollView.showsVerticalScrollIndicator = NO;
        _paggingScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _paggingScrollView;
}

- (THTinderNavigationBar *)paggingNavbar {
    [self view];
    if (!_paggingNavbar) {
        _paggingNavbar = [[THTinderNavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
        _paggingNavbar.backgroundColor = [UIColor clearColor];
        _paggingNavbar.navigationController = self;
        _paggingNavbar.itemViews = self.navbarItemViews;
        [self.view addSubview:_paggingNavbar];
    }
    return _paggingNavbar;
}

- (UIViewController *)getPageViewControllerAtIndex:(NSUInteger)index {
    if (index < self.paggedViewControllers.count) {
        return self.paggedViewControllers[index];
    } else {
        return nil;
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (_currentPage == currentPage)
        return;
    _currentPage = currentPage;

    //so that nav bar starts on the middle page
    self.paggingNavbar.currentPage = currentPage + 1;

    [self setupScrollToTop];
    [self callBackChangedPage];
}

- (void)setNavbarItemViews:(NSArray *)navbarItemViews {
    _navbarItemViews = navbarItemViews;
    self.paggingNavbar.itemViews = navbarItemViews;
    [self.paggingNavbar reloadData];
}

- (void)setNavbarLeftAccessoryView:(UIView *)view {
    _navbarLeftAccessoryView = view;
    self.paggingNavbar.leftAccessoryView = view;
    [self.paggingNavbar reloadData];
}

#pragma mark - Life Cycle

- (void)setupTargetViewController:(UIViewController *)targetViewController withSlideType:(THSlideType)slideType {
    if (!targetViewController)
        return;

    [self addChildViewController:targetViewController];
    CGRect targetViewFrame = targetViewController.view.frame;
    switch (slideType) {
        case THSlideTypeLeft: {
            targetViewFrame.origin.x = -CGRectGetWidth(self.view.bounds);
            break;
        }
        case THSlideTypeRight: {
            targetViewFrame.origin.x = CGRectGetWidth(self.view.bounds) * 2;
            break;
        }
        default:
            break;
    }
    targetViewController.view.frame = targetViewFrame;
    [self.view insertSubview:targetViewController.view atIndex:0];
    [targetViewController didMoveToParentViewController:self];
}

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController {
    return [self initWithLeftViewController:leftViewController rightViewController:nil];
}

- (instancetype)initWithRightViewController:(UIViewController *)rightViewController {
    return [self initWithLeftViewController:nil rightViewController:rightViewController];
}

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController {
    self = [super init];
    if (self) {
        self.leftViewController = leftViewController;

        self.rightViewController = rightViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setupViews];

    [self reloadData];
    
    [self.view layoutIfNeeded];
}

- (void)setupViews {
    [self.view addSubview:self.centerContainerView];
    [self.view addSubview:self.paggingNavbar];

    self.centerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.paggingNavbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.paggingNavbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:64]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.paggingNavbar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.paggingNavbar attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.paggingNavbar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.centerContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.paggingNavbar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.centerContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.centerContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.centerContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

    [self setupTargetViewController:self.leftViewController withSlideType:THSlideTypeLeft];
    [self setupTargetViewController:self.rightViewController withSlideType:THSlideTypeRight];
}

- (void)dealloc {
    self.paggingScrollView.delegate = nil;
    self.paggingScrollView = nil;

    self.paggingNavbar = nil;

    self.paggedViewControllers = nil;

    self.didChangedPageCompleted = nil;
}

#pragma mark - PanGesture Handle Method

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint contentOffset = self.paggingScrollView.contentOffset;

    CGSize contentSize = self.paggingScrollView.contentSize;

    CGFloat baseWidth = CGRectGetWidth(self.paggingScrollView.bounds);

    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:

            break;
        case UIGestureRecognizerStateChanged: {
            if (contentOffset.x <= 0) {
                [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
            } else if (contentOffset.x >= contentSize.width - baseWidth) {
                [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
            }
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            break;
        }
        default:
            break;
    }
}

#pragma mark - Block Call Back Method

- (void)callBackChangedPage {
    if (self.didChangedPageCompleted) {
        UIViewController *currentViewController = self.paggedViewControllers[self.currentPage];
        self.didChangedPageCompleted(self.currentPage, currentViewController.title);
    }
}

#pragma mark - TableView Helper Method

- (void)setupScrollToTop {
    for (NSUInteger i = 0; i < self.paggedViewControllers.count; i++) {
        UITableView *tableView = (UITableView *) [self subviewWithClass:[UITableView class] onView:[self getPageViewControllerAtIndex:i].view];
        if (tableView) {
            if (self.currentPage == i) {
                [tableView setScrollsToTop:YES];
            } else {
                [tableView setScrollsToTop:NO];
            }
        }
    }
}

#pragma mark - View Helper Method

- (UIView *)subviewWithClass:(Class)cuurentClass onView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:cuurentClass]) {
            return subView;
        }
    }
    return nil;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.paggingNavbar.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.paggingScrollView.frame);
    self.currentPage = (NSUInteger) (floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
}

@end
