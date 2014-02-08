//
//  AssetCell.h
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-6.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AssetCell;

@protocol AssetCellDelegate <NSObject>

-(void)assetCell:(AssetCell*)cell didDelete:(NSString*)image;

@end

@interface AssetCell : UICollectionViewCell

@property (weak,nonatomic) id<AssetCellDelegate> delegete;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic,strong) NSString * imageFile;

- (IBAction)delete:(id)sender;

@end
