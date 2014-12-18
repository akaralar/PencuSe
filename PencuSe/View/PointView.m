//
//  PointView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "PointView.h"
#import "Masonry.h"
#import "CheckerView.h"

static const NSInteger kMaxCheckersToDisplay = 5;

@interface PointView ()

@property (nonatomic, readwrite) PointDirection pointDirection;
@property (nonatomic, readwrite) PointColor pointColor;

@property (nonatomic) NSMutableArray *checkerViews;

@property (nonatomic, readonly) CAShapeLayer *layer;

- (UIBezierPath *)pathForPointDirection:(PointDirection)pointDirection;
- (void)addConstraintsForCheckerView:(CheckerView *)checkerView;

@end

@implementation PointView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithIndex:(NSInteger)index
{
    self = [super initWithIndex:index];

    if (!self) {
        return nil;
    }

    self.layer.backgroundColor = [UIColor boardInteriorColor].CGColor;
    self.layer.delegate = self;

    return self;
}

- (instancetype)initWithPointDirection:(PointDirection)direction
                            pointColor:(PointColor)color
                            pointIndex:(NSInteger)index
{
    self = [self initWithIndex:index];

    if (!self) {
        return nil;
    }

    _pointDirection = direction;
    _pointColor = color;

    _checkerViews = [NSMutableArray array];

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    self.layer.backgroundColor = [UIColor boardInteriorColor].CGColor;
    self.layer.delegate = self;

    return self;
}

- (void)addConstraintsForCheckerView:(CheckerView *)checkerView
{
    [checkerView mas_remakeConstraints:^(MASConstraintMaker *make) {

        BOOL pointIsInTopHalf = self.pointDirection == PointDirectionDown;

        MASConstraint *constraint;
        MASViewAttribute *attribute;
        if (self.checkerViews.count == 0) {

            attribute = pointIsInTopHalf ? self.mas_top : self.mas_bottom;
            constraint = pointIsInTopHalf ? make.top : make.bottom;
        }
        else {

            CheckerView *checkerToAlign = [self.checkerViews lastObject];

            if (self.checkerViews.count > kMaxCheckersToDisplay - 1) {

                checkerToAlign = self.checkerViews[kMaxCheckersToDisplay - 2];
            }

            attribute = pointIsInTopHalf ? checkerToAlign.mas_bottom : checkerToAlign.mas_top;
            constraint = pointIsInTopHalf ? make.top : make.bottom;

        }

        constraint.equalTo(attribute);
        make.centerX.equalTo(self);

        make.width.and.height.equalTo(self.mas_height).multipliedBy(1/5.5);
    }];
}

- (void)insertCheckerView:(CheckerView *)checkerView animated:(BOOL)animated
{
    [self addConstraintsForCheckerView:checkerView];

    if (animated) {

        [UIView animateWithDuration:0.2
                         animations:^{
                             [checkerView layoutIfNeeded];
                         }];
    }
    else {

        [checkerView layoutIfNeeded];
    }

    [self.checkerViews addObject:checkerView];
    checkerView.index = self.index;

    if (self.checkerViews.count > kMaxCheckersToDisplay) {
        
        checkerView.countLabel.text = [@(self.checkerViews.count) stringValue];
    }
}

- (void)removeCheckerView:(CheckerView *)checkerView
{
    [self.checkerViews removeObject:checkerView];
    checkerView.countLabel.text = @"";
}

- (CheckerView *)topCheckerView
{
    return [self.checkerViews lastObject];
}

#pragma mark - Convenience

- (UIBezierPath *)pathForPointDirection:(PointDirection)direction
{
    CGPoint vertice1, vertice2, vertice3;

    switch (direction) {

        case PointDirectionUp:

            vertice1 = CGPointMake(0, self.bounds.size.height);
            vertice2 = CGPointMake(self.bounds.size.width / 2, 0);
            vertice3 = CGPointMake(self.bounds.size.width, self.bounds.size.height);

            break;

        case PointDirectionDown:

            vertice1 = CGPointZero;
            vertice2 = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
            vertice3 = CGPointMake(self.bounds.size.width, 0);

            break;
    }

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:vertice1];
    [path addLineToPoint:vertice2];
    [path addLineToPoint:vertice3];
    [path closePath];

    return path;
}


#pragma mark - CALayerDelegate

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    self.layer.fillColor = [UIColor colorForPointColor:self.pointColor].CGColor;
    self.layer.path = [self pathForPointDirection:self.pointDirection].CGPath;
}

@end
