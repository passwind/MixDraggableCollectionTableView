//
//  EditMomentCell.m
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-6.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import "EditMomentCell.h"
#import "AssetCell.h"
#import "AddAssetCell.h"
#import "Constants.h"

@interface EditMomentCell()<AssetCellDelegate>

@end
@implementation EditMomentCell

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    _assets=[NSMutableArray array];
}

-(void)setAssets:(NSMutableArray *)assets
{
    [_assets removeAllObjects];
    
    [_assets addObjectsFromArray:assets];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self recalcCollectionViewHeight];
    return [_assets count]+1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[_assets count]) {
        AddAssetCell * cell=(AddAssetCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"AddAssetCell" forIndexPath:indexPath];
        return cell;
    }
    
    AssetCell * cell=(AssetCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.delegete=self;
    
    NSString * imageName=_assets[indexPath.row];
    
    cell.imageFile=imageName;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[_assets count]) {
        //add new set
        [_assets addObject:@"r2d2.jpg"];
        [self.collectionView reloadData];

        [self.delegate editMomentCell:self didAddAsset:@"r2d2.jpg"];
    }
    
    //TODO:edit picture
}

#pragma mark - AssetCellDelegate method
-(void)assetCell:(AssetCell *)cell didDelete:(NSString *)image
{
    if ([_assets containsObject:image]) {
        [_assets removeObject:image];
        [self.collectionView reloadData];
        
        [self.delegate editMomentCell:self didDeleteAsset:image];
    }
}

-(void)recalcCollectionViewHeight
{
    int rows=(int)ceil((double)([_assets count]+1)/3.0);
    CGFloat height=rows*kCollectionViewCellHeight+(rows+1)*kCollectionViewPadding;
    CGRect frame=self.collectionView.frame;
    frame.size.height=height;
    self.collectionView.frame=frame;
}

@end
