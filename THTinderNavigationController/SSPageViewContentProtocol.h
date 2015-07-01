//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

@protocol SSPageViewContentProtocol <NSObject>

@required
- (void)setPageIndex:(NSInteger)index;
- (NSInteger)pageIndex;
@end