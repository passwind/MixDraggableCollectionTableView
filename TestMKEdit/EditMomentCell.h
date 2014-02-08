//
//  EditMomentCell.h
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-6.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditMomentCell;

@protocol EditMomentCellDelegate <NSObject>

-(void)editMomentCell:(EditMomentCell*)cell didAddAsset:(NSString*)image;
-(void)editMomentCell:(EditMomentCell*)cell didDeleteAsset:(NSString*)image;

@end

@interface EditMomentCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak,nonatomic) id<EditMomentCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray * assets;

@end
