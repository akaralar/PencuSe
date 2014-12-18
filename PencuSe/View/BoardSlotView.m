//
//  BoardSlotView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 18/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardSlotView.h"

@interface BoardSlotView ()

@property (nonatomic, readwrite) CALayer *overlayLayer;
@property (nonatomic, readwrite) NSInteger index;

@end

@implementation BoardSlotView

- (instancetype)initWithIndex:(NSInteger)index
{
    self = [super initWithFrame:CGRectZero];

    if (!self) {
        return nil;
    }

    _index = index;

    return self;
}

#pragma mark - Accessors

- (void)setHightlightColor:(PointHighlightColor)hightlightColor
{
    _hightlightColor = hightlightColor;

    switch (hightlightColor) {
        case PointHighlightColorNone:

            self.overlayLayer.opacity = 0;
            self.overlayLayer.backgroundColor = [UIColor clearColor].CGColor;
            break;

        case PointHighlightColorAllowed:
        case PointHighlightColorForbidden:
        case PointHighlightColorSelected:
            self.overlayLayer.opacity = 0.4;
            self.overlayLayer.backgroundColor = [UIColor
                                                 colorForPointHighlightColor:hightlightColor].CGColor;
            break;
        default:
            break;
    }

    // make sure overlay is always on top
    [self.layer addSublayer:self.overlayLayer];
}

- (CALayer *)overlayLayer
{
    if (!_overlayLayer) {

        _overlayLayer = [CALayer layer];
        [self.layer addSublayer:_overlayLayer];
        _overlayLayer.frame = self.layer.bounds;
    }
    
    return _overlayLayer;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    self.overlayLayer.frame = self.layer.bounds;
}

@end
