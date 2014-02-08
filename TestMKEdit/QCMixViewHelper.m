//
//  QCMixViewHelper.m
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-7.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import "QCMixViewHelper.h"
#import "QCMixTableViewDataSource_Draggable.h"
#import "EditMomentCell.h"

#import "DraggableCollectionViewFlowLayout.h"

#ifndef CGGEOMETRY__SUPPORT_H_
CG_INLINE CGPoint
_CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif

typedef NS_ENUM(NSInteger, _ScrollingDirection) {
    _ScrollingDirectionUnknown = 0,
    _ScrollingDirectionUp,
    _ScrollingDirectionDown,
    _ScrollingDirectionLeft,
    _ScrollingDirectionRight
};

@interface QCMixViewHelper()
{
    NSIndexPath * lastIndexPath;
    UIImageView * mockCell;
    CGPoint mockCenter;
    CGPoint fingerTranslation;
    CADisplayLink *timer;
    _ScrollingDirection scrollingDirection;
}

@property (strong, nonatomic) NSIndexPath *fromIndexPath;
@property (strong, nonatomic) NSIndexPath *toIndexPath;
@property (strong, nonatomic) NSIndexPath *hideIndexPath;

@end

@implementation QCMixViewHelper

-(id)initWithTableView:(UITableView *)tableView
{
    self=[super init];
    if (self) {
        _tableView=tableView;
        
        _scrollingEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
        _scrollingSpeed = 300.f;
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleLongPressGesture:)];
        _longPressGestureRecognizer.delegate=self;
        [_tableView addGestureRecognizer:_longPressGestureRecognizer];
        
        _panPressGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handlePanGesture:)];
        _panPressGestureRecognizer.delegate = self;
        
        [_tableView addGestureRecognizer:_panPressGestureRecognizer];
        
        for (UIGestureRecognizer *gestureRecognizer in _tableView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
                break;
            }
        }
        
        //TODO:有必要么？
        for (EditMomentCell * cell in [_tableView visibleCells]) {
            UICollectionView * cv=cell.collectionView;
            for (UIGestureRecognizer *gestureRecognizer in cv.gestureRecognizers) {
                if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                    [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
                    break;
                }
            }
        }
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    _longPressGestureRecognizer.enabled = enabled;
    _panPressGestureRecognizer.enabled = enabled;
}

#pragma mark - misc functions

//选择当前点击的asset，table的row为section，collection的item为item，生成新的indexpath
- (NSIndexPath *)indexPathForItemClosestToPoint:(CGPoint)point0
{
    NSIndexPath * tableIndex=[self.tableView indexPathForRowAtPoint:point0];
    EditMomentCell * tableCell=(EditMomentCell*)[self.tableView cellForRowAtIndexPath:tableIndex];
    UICollectionView * collectionView=tableCell.collectionView;
    
    //转换到collectionview
    CGPoint point=[collectionView convertPoint:point0 fromView:self.tableView];
    
    NSArray *layoutAttrsInRect;
    NSInteger closestDist = NSIntegerMax;
    NSIndexPath *indexPath;
    
    // We need original positions of cells
    DraggableCollectionViewFlowLayout * flowLayout=(DraggableCollectionViewFlowLayout*)collectionView.collectionViewLayout;

    if (tableIndex.row==self.fromIndexPath.section) {
        flowLayout.layoutHelper.hideIndexPath=self.fromIndexPath;
    }
    
    layoutAttrsInRect = [flowLayout layoutAttributesForElementsInRect:collectionView.bounds];
    
    // What cell are we closest to?
    for (UICollectionViewLayoutAttributes *layoutAttr in layoutAttrsInRect) {
        CGFloat xd = layoutAttr.center.x - point.x;
        CGFloat yd = layoutAttr.center.y - point.y;
        NSInteger dist = sqrtf(xd*xd + yd*yd);
        if (dist < closestDist) {
            closestDist = dist;
            indexPath = layoutAttr.indexPath;
        }
    }
    
    // Are we closer to being the last cell in a different section?
    NSInteger sections = [_tableView numberOfRowsInSection:0];
    for (NSInteger i = 0; i < sections; ++i) {
        if (i == self.fromIndexPath.section) {
            continue;
        }
        NSIndexPath * tmpTableIndex=[NSIndexPath indexPathForRow:i inSection:0];
        EditMomentCell * tmpTableCell=(EditMomentCell*)[_tableView cellForRowAtIndexPath:tmpTableIndex];
        UICollectionView * tmpCollectionView=tmpTableCell.collectionView;
        
        NSInteger items = [tmpCollectionView numberOfItemsInSection:0];
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:items inSection:0];
        UICollectionViewLayoutAttributes *layoutAttr;
        CGFloat xd, yd;
        
        layoutAttr = [tmpCollectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:nextIndexPath];
        xd = layoutAttr.center.x - point.x;
        yd = layoutAttr.center.y - point.y;
        
        NSInteger dist = sqrtf(xd*xd + yd*yd);
        if (dist < closestDist) {
            closestDist = dist;
            indexPath = layoutAttr.indexPath;
        }
    }
    
    //OK,translate to new IndexPath
    NSIndexPath * newIndexPath=[NSIndexPath indexPathForItem:indexPath.item inSection:tableIndex.row];
    
    return newIndexPath;
}

-(UICollectionViewCell*)cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionView * collectionView=[self collectionViewAtIndexPath:indexPath];
    
    NSIndexPath * cvIndex=[NSIndexPath indexPathForItem:indexPath.item inSection:0];
    UICollectionViewCell * cell=[collectionView cellForItemAtIndexPath:cvIndex];
    
    return cell;
}

- (UIImage *)imageFromCell:(UICollectionViewCell *)cell {
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.isOpaque, 0.0f);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UICollectionView*)collectionViewAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath * tableIndex=[NSIndexPath indexPathForRow:indexPath.section inSection:0];
    EditMomentCell * tableCell=(EditMomentCell*)[_tableView cellForRowAtIndexPath:tableIndex];
    UICollectionView * collectionView=tableCell.collectionView;
    
    return collectionView;
}

- (void)invalidatesScrollTimer {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    scrollingDirection = _ScrollingDirectionUnknown;
}

- (void)setupScrollTimerInDirection:(_ScrollingDirection)direction {
    scrollingDirection = direction;
    if (timer == nil) {
        timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScroll:)];
        [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)handleScroll:(NSTimer *)timer {
    if (scrollingDirection == _ScrollingDirectionUnknown) {
        return;
    }
    
    CGSize frameSize = self.tableView.bounds.size;
    CGSize contentSize = self.tableView.contentSize;
    CGPoint contentOffset = self.tableView.contentOffset;
    CGFloat distance = self.scrollingSpeed / 60.f;
    CGPoint translation = CGPointZero;
    
    switch(scrollingDirection) {
        case _ScrollingDirectionUp: {
            distance = -distance;
            if ((contentOffset.y + distance) <= 0.f) {
                distance = -contentOffset.y;
            }
            translation = CGPointMake(0.f, distance);
        } break;
        case _ScrollingDirectionDown: {
            CGFloat maxY = MAX(contentSize.height, frameSize.height) - frameSize.height;
            if ((contentOffset.y + distance) >= maxY) {
                distance = maxY - contentOffset.y;
            }
            translation = CGPointMake(0.f, distance);
        } break;
        case _ScrollingDirectionLeft: {//TODO:unused
            distance = -distance;
            if ((contentOffset.x + distance) <= 0.f) {
                distance = -contentOffset.x;
            }
            translation = CGPointMake(distance, 0.f);
        } break;
        case _ScrollingDirectionRight: {//TODO:unused
            CGFloat maxX = MAX(contentSize.width, frameSize.width) - frameSize.width;
            if ((contentOffset.x + distance) >= maxX) {
                distance = maxX - contentOffset.x;
            }
            translation = CGPointMake(distance, 0.f);
        } break;
        default: break;
    }
    
    mockCenter  = _CGPointAdd(mockCenter, translation);
    mockCell.center = _CGPointAdd(mockCenter, fingerTranslation);
    self.tableView.contentOffset = _CGPointAdd(contentOffset, translation);
    
    // Warp items while scrolling
    NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:mockCell.center];
    [self warpToIndexPath:indexPath];
}

- (void)warpToIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath == nil || [lastIndexPath isEqual:indexPath]) {
        return;
    }
    lastIndexPath = indexPath;
    
    if ([(id<QCMixTableViewDataSource_Draggable>)self.tableView.dataSource
            qcMixTableView:self.tableView
            canMoveItemAtIndexPath:self.fromIndexPath
            toIndexPath:indexPath] == NO) {
            return;
        }
    
    self.hideIndexPath = indexPath;
    self.toIndexPath = indexPath;
}

-(NSIndexPath*)cvIndexPathAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath * cvIndex=[NSIndexPath indexPathForItem:indexPath.item inSection:0];
    return cvIndex;
}

#pragma mark - Gesture handle functions
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        return;
    }
    if (![self.tableView.dataSource conformsToProtocol:@protocol(QCMixTableViewDataSource_Draggable)]) {
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:[sender locationInView:self.tableView]];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath == nil) {
                return;
            }
            if (![(id<QCMixTableViewDataSource_Draggable>)_tableView.dataSource
                  qcMixTableView:_tableView canMoveItemAtIndexPath:indexPath]) {
                return;
            }
            // Create mock cell to drag around
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
            UICollectionView * collectionView=[self collectionViewAtIndexPath:indexPath];
            
            cell.highlighted = NO;
            [mockCell removeFromSuperview];
            mockCell = [[UIImageView alloc] initWithFrame:cell.frame];
            mockCell.image = [self imageFromCell:cell];
            mockCell.center=[self.tableView convertPoint:mockCell.center fromView:collectionView];
            
            mockCenter = mockCell.center;
            [_tableView addSubview:mockCell];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 mockCell.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
             }
             completion:nil];
            
            // Start warping
            lastIndexPath = indexPath;
            self.fromIndexPath = indexPath;
            self.hideIndexPath = indexPath;
            self.toIndexPath = indexPath;
            
            DraggableCollectionViewFlowLayout * flowLayout=(DraggableCollectionViewFlowLayout*)collectionView.collectionViewLayout;
            
            flowLayout.layoutHelper.hideIndexPath=[self cvIndexPathAtIndexPath:self.fromIndexPath];
            flowLayout.layoutHelper.hideFlag=YES;
            
            [flowLayout invalidateLayout];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if(self.fromIndexPath == nil) {
                return;
            }
            // Tell the data source to move the item
            [(id<QCMixTableViewDataSource_Draggable>)self.tableView.dataSource qcMixTableView:self.tableView
                                                                                 moveItemAtIndexPath:self.fromIndexPath
                                                                                         toIndexPath:self.toIndexPath];
            
            UICollectionView * collectionView=[self collectionViewAtIndexPath:self.fromIndexPath];
            DraggableCollectionViewFlowLayout * flowLayout=(DraggableCollectionViewFlowLayout*)collectionView.collectionViewLayout;
            
            flowLayout.layoutHelper.hideIndexPath=[self cvIndexPathAtIndexPath:self.fromIndexPath];
            flowLayout.layoutHelper.hideFlag=NO;
            [flowLayout invalidateLayout];
            
            self.fromIndexPath=nil;
            self.toIndexPath=nil;
            
            collectionView=[self collectionViewAtIndexPath:indexPath];
            
            // Switch mock for cell
            UICollectionViewLayoutAttributes *layoutAttributes = [collectionView layoutAttributesForItemAtIndexPath:[self cvIndexPathAtIndexPath:self.hideIndexPath]];
            CGPoint lastPoint=[self.tableView convertPoint:layoutAttributes.center fromView:collectionView];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 mockCell.center=lastPoint;
                 mockCell.transform = CGAffineTransformMakeScale(1.f, 1.f);
             }
             completion:^(BOOL finished) {
                 [mockCell removeFromSuperview];
                 mockCell = nil;
                 self.hideIndexPath = nil;
             }];
            
            // Reset
            [self invalidatesScrollTimer];
            lastIndexPath = nil;
        } break;
        default: break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateChanged) {
        // Move mock to match finger
        fingerTranslation = [sender translationInView:self.tableView];
        mockCell.center = _CGPointAdd(mockCenter, fingerTranslation);
        
        // Scroll when necessary
        if (mockCell.center.y < (CGRectGetMinY(self.tableView.bounds) + self.scrollingEdgeInsets.top)) {
            [self setupScrollTimerInDirection:_ScrollingDirectionUp];
        }
        else {
            if (mockCell.center.y > (CGRectGetMaxY(self.tableView.bounds) - self.scrollingEdgeInsets.bottom)) {
                [self setupScrollTimerInDirection:_ScrollingDirectionDown];
            }
            else {
                [self invalidatesScrollTimer];
            }
        }
        
        // Avoid warping a second time while scrolling
        if (scrollingDirection > _ScrollingDirectionUnknown) {
            return;
        }
        
        // Warp item to finger location

        NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:[sender locationInView:self.tableView]];
        
        [self warpToIndexPath:indexPath];
    }
}

#pragma mark - UIGestureRecognizerDelegate functions

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:_longPressGestureRecognizer]) {
        CGPoint point=[gestureRecognizer locationInView:_tableView];
        NSIndexPath * tableIndex=[self.tableView indexPathForRowAtPoint:point];
        
        EditMomentCell * tableCell=(EditMomentCell*)[self.tableView cellForRowAtIndexPath:tableIndex];
        UICollectionView * collectionView=tableCell.collectionView;
        
        if (point.x>collectionView.frame.origin.x+collectionView.frame.size.width)
        {
            return NO;
        }
    }

    if([gestureRecognizer isEqual:_panPressGestureRecognizer]) {
        return self.fromIndexPath != nil;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isEqual:_longPressGestureRecognizer]) {
        return [otherGestureRecognizer isEqual:_panPressGestureRecognizer];
    }
    
    if ([gestureRecognizer isEqual:_panPressGestureRecognizer]) {
        return [otherGestureRecognizer isEqual:_longPressGestureRecognizer];
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isEqual:_longPressGestureRecognizer]
        ||[gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint point=[gestureRecognizer locationInView:_tableView];
        NSIndexPath * tableIndex=[self.tableView indexPathForRowAtPoint:point];
        
        EditMomentCell * tableCell=(EditMomentCell*)[self.tableView cellForRowAtIndexPath:tableIndex];
        UICollectionView * collectionView=tableCell.collectionView;
        
        if (point.x>collectionView.frame.origin.x+collectionView.frame.size.width)
        {
            return NO;
        }
    }
    
    return YES;
}

@end
