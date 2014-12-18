//
//  PointView.h
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardSlotView.h"

typedef NS_ENUM(NSInteger, PointDirection) {
    PointDirectionUp,
    PointDirectionDown
};

@class CheckerView;

@interface PointView : BoardSlotView

@property (nonatomic, readonly) PointDirection pointDirection;
@property (nonatomic, readonly) PointColor pointColor;

- (instancetype)initWithPointDirection:(PointDirection)direction
                            pointColor:(PointColor)color
                            pointIndex:(NSInteger)index;

- (void)insertCheckerView:(CheckerView *)checkerView animated:(BOOL)animated;
- (void)removeCheckerView:(CheckerView *)checkerView;
- (CheckerView *)topCheckerView;

@end
