//
//  UIColor+PencuSeAdditions.m
//  PencuSe
//
//  Created by Ahmet Karalar on 30/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "UIColor+PencuSeAdditions.h"

@implementation UIColor (PencuSeAdditions)

+ (UIColor *)boardInteriorColor
{
    return [UIColor colorWithRed:0.222
                           green:0.212
                            blue:0.197
                           alpha:1];
}

+ (UIColor *)boardWoodColor
{
    return [UIColor colorWithRed:0.563
                           green:0.332
                            blue:0.264
                           alpha:1];
}

+ (UIColor *)colorForPointColor:(PointColor)pointColor
{
    UIColor *color;
    switch (pointColor) {
        case PointColorRed:
            color = [UIColor colorWithRed:0.863 green:0.131 blue:0.052 alpha:1];
            break;
        case PointColorWhite:
            color = [UIColor colorWithRed:0.999 green:1 blue:1 alpha:1];
            break;
    }

    return color;
}

+ (UIColor *)colorForCheckerColor:(CheckerColor)checkerColor
{
    UIColor *color;
    switch (checkerColor) {

        case CheckerColorRed:
            color = [UIColor colorWithRed:0.863 green:0.131 blue:0.052 alpha:1];
            break;

        case CheckerColorBlack:
            color = [UIColor colorWithRed:0.306 green:0.292 blue:0.287 alpha:1];
            break;
    }
    
    return color;
}

+ (UIColor *)colorForPointHighlightColor:(PointHighlightColor)highlightColor
{
    UIColor *color;
    switch (highlightColor) {
        case PointHighlightColorNone:
            color = nil;
            break;

        case PointHighlightColorAllowed:
            color = [UIColor greenColor];
            break;

        case PointHighlightColorForbidden:
            color = [UIColor redColor];
            break;

        case PointHighlightColorSelected:
            color = [UIColor yellowColor];
            break;
    }

    return color;
}

@end
