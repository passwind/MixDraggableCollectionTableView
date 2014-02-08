//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "LSCollectionViewLayoutHelper.h"

@interface LSCollectionViewLayoutHelper ()

@end

@implementation LSCollectionViewLayoutHelper

- (id)initWithCollectionViewLayout:(UICollectionViewLayout<UICollectionViewLayout_Warpable>*)collectionViewLayout
{
    self = [super init];
    if (self) {
        _collectionViewLayout = collectionViewLayout;
    }
    return self;
}

- (NSArray *)modifiedLayoutAttributesForElements:(NSArray *)elements
{
    NSIndexPath *hideIndexPath = self.hideIndexPath;
    
    if (hideIndexPath == nil) {
        return elements;
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in elements) {
        if(layoutAttributes.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        if ([layoutAttributes.indexPath isEqual:hideIndexPath]) {
            layoutAttributes.hidden = self.hideFlag;
        }
    }
    return elements;
}

@end
