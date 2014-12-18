//
//  BoardView.h
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+PencuSeAdditions.h"

@class CheckerView;

@interface BoardView : UIView

@property (nonatomic, readonly) NSArray *pointViews;
@property (nonatomic, readonly) NSArray *checkerViews;
@property (nonatomic, readonly) CheckerView *selectedCheckerView;
@property (nonatomic, readonly) NSInteger selectedCheckerIndex;

- (void)highlightIndex:(NSInteger)index withColor:(PointHighlightColor)highlightColor;
- (void)deselectChecker;
- (void)unhighlightAll;

- (CheckerView *)topCheckerAtIndex:(NSInteger)index forColor:(CheckerColor)color;
- (NSInteger)pointViewIndexForTouch:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)selectTopCheckerForTouch:(UITouch *)touch
                       withEvent:(UIEvent *)event
                        forColor:(CheckerColor)color;

- (void)createCheckerWithColor:(CheckerColor)color
                       atIndex:(NSInteger)index;
- (void)placeChecker:(CheckerView *)checker
             atIndex:(NSInteger)index
            animated:(BOOL)animated;

@end
