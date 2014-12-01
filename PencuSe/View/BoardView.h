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

@property (nonatomic, readonly) NSArray *checkerViews;

- (void)highlightIndex:(NSInteger)index withColor:(PointHighlightColor)highlightColor;
- (void)unhighlightAll;

- (void)placeChecker:(CheckerView *)checker atIndex:(NSInteger)index animated:(BOOL)animated;

@end
