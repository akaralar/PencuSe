//
//  CheckerView.h
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+PencuSeAdditions.h"

@interface CheckerView : UIView

@property (nonatomic) CheckerColor color;
@property (nonatomic) NSInteger index;
@property (nonatomic) UILabel *countLabel; // when there are more than 1 checker at the same space

@end
