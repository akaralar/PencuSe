//
//  UIColor+PencuSeAdditions.h
//  PencuSe
//
//  Created by Ahmet Karalar on 30/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>

// import Checker for CheckerColor enum
#import "Checker.h"

typedef NS_ENUM(NSInteger, PointColor) {
    PointColorRed,
    PointColorWhite
};

typedef NS_ENUM(NSInteger, PointHighlightColor) {
    PointHighlightColorNone,
    PointHighlightColorAllowed,
    PointHighlightColorForbidden,
    PointHighlightColorSelected
};

@interface UIColor (PencuSeAdditions)

+ (UIColor *)boardInteriorColor;
+ (UIColor *)boardWoodColor;

+ (UIColor *)colorForCheckerColor:(CheckerColor)checkerColor;
+ (UIColor *)colorForPointColor:(PointColor)pointColor;
+ (UIColor *)colorForPointHighlightColor:(PointHighlightColor)highlightColor;

@end
