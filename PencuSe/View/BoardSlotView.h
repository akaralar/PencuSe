//
//  BoardSlotView.h
//  PencuSe
//
//  Created by Ahmet Karalar on 18/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+PencuSeAdditions.h"

@interface BoardSlotView : UIView

@property (nonatomic) PointHighlightColor hightlightColor; // animated
@property (nonatomic, readonly) CALayer *overlayLayer;
@property (nonatomic, readonly) NSInteger index;

- (instancetype)initWithIndex:(NSInteger)index;

@end
