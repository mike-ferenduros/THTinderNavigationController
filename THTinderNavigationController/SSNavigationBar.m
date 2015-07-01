//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

#import "SSNavigationBar.h"
#import "SSSlidingNavigationController.h"

#define WIDTH self.bounds.size.width
#define IMAGESIZE 38
#define Y_POSITION 24

static CGFloat MARGIN = 15.0;

@interface SSNavigationBar ()

@end

@implementation SSNavigationBar

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark - Properties

- (void)setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;

    CGFloat xOffset = contentOffset.x;

    CGFloat normalWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);

    [self.itemViews enumerateObjectsUsingBlock:^(UIView <SSNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {

        CGFloat width = (WIDTH - MARGIN * 2);
        CGFloat step = (width / 2 - IMAGESIZE / 2);// * idx;

        CGRect itemViewFrame = itemView.frame;
        itemViewFrame.origin.x = MARGIN + step * idx - xOffset / normalWidth * step + step;
        itemView.frame = itemViewFrame;

        CGFloat ratio;
        if (xOffset < normalWidth * idx) {
            ratio = (xOffset - normalWidth * (idx - 1)) / normalWidth;
        } else {
            ratio = 1 - ((xOffset - normalWidth * idx) / normalWidth);
        }

        [self updateItemView:itemView withRatio:ratio];
    }];
}

- (void)setItemViews:(NSArray *)itemViews {
    if (itemViews) {

        [self.itemViews enumerateObjectsUsingBlock:^(UIView <SSNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {
            [itemView removeFromSuperview];
        }];

        [itemViews enumerateObjectsUsingBlock:^(UIView <SSNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {
            itemView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
            [itemView addGestureRecognizer:tapGesture];
            [self addSubview:itemView];
        }];
    }

    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandle:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandle:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;

    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [self addGestureRecognizer:swipeRightGestureRecognizer];

    _itemViews = itemViews;
}

#pragma mark - DataSource

- (void)reloadData {
    if (!self.itemViews.count) {
        return;
    }

    [self.itemViews enumerateObjectsUsingBlock:^(UIView <SSNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {

        CGFloat width = (WIDTH - MARGIN * 2);
        CGFloat step = (width / 2 - MARGIN) * idx;
        CGRect itemViewFrame = CGRectMake(step - MARGIN / 2, Y_POSITION, IMAGESIZE, IMAGESIZE);
        itemView.hidden = NO;
        itemView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        itemView.frame = itemViewFrame;

        if (self.currentPage + 1 == idx) {
            [self updateItemView:itemView withRatio:1.0];
        } else {
            [self updateItemView:itemView withRatio:0.0];
        }
    }];

    // Dirty hack
    [self setContentOffset:self.contentOffset];
}

#pragma mark - Gesture Handlers

- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture {
    NSUInteger pageIndex = [self.itemViews indexOfObject:tapGesture.view];
    [self.slidingNavigationController setCurrentPage:pageIndex animated:YES];
}

- (void)swipeGestureHandle:(UISwipeGestureRecognizer *)swipeGesture {

    NSInteger nextPageIndex = [self.slidingNavigationController currentPageIndex];
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        if (nextPageIndex > 0 && nextPageIndex <= self.itemViews.count - 1) {
            nextPageIndex--;
        }
    } else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (nextPageIndex < self.itemViews.count - 1) {
            nextPageIndex++;
        }
    }
    [self.slidingNavigationController setCurrentPage:(NSUInteger) nextPageIndex animated:YES];
}

#pragma mark - Other

- (void)updateItemView:(UIView <SSNavigationBarItem> *)itemView withRatio:(CGFloat)ratio {
    if ([itemView respondsToSelector:@selector(updateViewWithRatio:)]) {
        [itemView updateViewWithRatio:ratio];
    }
}


@end

