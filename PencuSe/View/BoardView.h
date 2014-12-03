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

- (void)highlightIndex:(NSInteger)index withColor:(PointHighlightColor)highlightColor;
- (void)selectTopCheckerAtIndex:(NSInteger)index;
- (void)deselectChecker;
- (void)unhighlightAll;

- (void)placeChecker:(CheckerView *)checker
             atIndex:(NSInteger)index
            animated:(BOOL)animated;

- (NSInteger)pointViewIndexForTouch:(UITouch *)touch withEvent:(UIEvent *)event;

@end
