//
//  AssetCell.m
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-6.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import "AssetCell.h"

@implementation AssetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)delete:(id)sender {
    [self.delegete assetCell:self didDelete:_imageFile];
}

-(void)setImageFile:(NSString *)filename
{
    if (_imageFile!=filename) {
        _imageFile=filename;
    }
    _imageView.image=[UIImage imageNamed:_imageFile];
}
@end
