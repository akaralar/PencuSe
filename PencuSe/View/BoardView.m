//
//  BoardView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardView.h"
#import "PointView.h"
#import "Masonry.h"
#import "CheckerView.h"
#import <BlocksKit/BlocksKit.h>

// A point is the slot a checker can move to
static const NSInteger kNumberOfPoints = 24;

// 12 points plus middle bar and side paddings equal to 2 point widths in total
static const CGFloat kPointWidthToTotalWidthRatio = 1 / 14.0;

// 0.1 of total height is board padding (0.05 on top and bottom each)
// there are 2 rows of points, (1 - 0.1) / 2 = 0.45
static const CGFloat kPointHeightToTotalHeightRatio = 0.45;

@interface BoardView ()

@property (nonatomic) NSMutableArray *points;
@property (nonatomic) NSMutableArray *checkers;

@property (nonatomic) CheckerView *selectedCheckerView;

- (PointView *)pointViewAtIndex:(NSInteger)index;
- (void)willHighlightIndex:(NSInteger)index;

- (CheckerView *)topCheckerAtIndex:(NSInteger)index;
@end

@implementation BoardView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    self.backgroundColor = [UIColor boardWoodColor];

    _points = [NSMutableArray array];

    for (NSInteger i = 0; i < kNumberOfPoints; ++i) {

        PointView *pointView = [[PointView alloc] initWithFrame:CGRectZero];
        pointView.pointColor = (i % 2 == 0) ? PointColorRed : PointColorWhite;
        pointView.pointDirection = i / (kNumberOfPoints / 2.0) < 1 ? PointDirectionDown : PointDirectionUp;
        pointView.pointIndex = i;
        [_points addObject:pointView];
        [self addSubview:pointView];


        CGFloat leftPaddingMultiplier = kPointWidthToTotalWidthRatio / 2;
        CGFloat leftEdgeMultiplier;
        if (i < kNumberOfPoints / 2) {

            leftEdgeMultiplier = leftPaddingMultiplier + (i * kPointWidthToTotalWidthRatio);
        }
        else {
            leftEdgeMultiplier = leftPaddingMultiplier + ((kNumberOfPoints - i - 1) * kPointWidthToTotalWidthRatio);
        }

        if (i >= kNumberOfPoints / 4 &&
            i < kNumberOfPoints - (kNumberOfPoints / 4)) {

            leftEdgeMultiplier += 2 * leftPaddingMultiplier;
        }

        CGFloat topPaddingMultiplier = (1 - 2 * kPointHeightToTotalHeightRatio) / 2.0;
        CGFloat topEdgeMultiplier = topPaddingMultiplier + i / (kNumberOfPoints / 2) * kPointHeightToTotalHeightRatio;

        [pointView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(self.mas_right).multipliedBy(leftEdgeMultiplier);
            make.top.equalTo(self.mas_bottom).multipliedBy(topEdgeMultiplier);
            make.width.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
            make.height.equalTo(self.mas_height).multipliedBy(kPointHeightToTotalHeightRatio);
        }];

        // put index labels above or below points
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.text = @(pointView.pointIndex + 1).stringValue;

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {

            indexLabel.font = [UIFont systemFontOfSize:10];
        }

        [self addSubview:indexLabel];

        [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.centerX.equalTo(pointView);

            if (i + 1 > (kNumberOfPoints / 2)) {

                make.top.equalTo(pointView.mas_bottom).with.offset(2);
            }
            else {
                make.bottom.equalTo(pointView.mas_top).with.offset(-2);
            }
        }];
    }


    _checkers = [NSMutableArray array];

    CheckerView *checker = [[CheckerView alloc] initWithFrame:CGRectZero];

    checker.color = CheckerColorRed;

    [self addSubview:checker];
    [_checkers addObject:checker];

    [checker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
        make.center.equalTo([self pointViewAtIndex:0]);
    }];


//    for (NSInteger i = 0; i < 30; ++i) {
//
//        CheckerView *view = [[CheckerView alloc] initWithFrame:CGRectZero];
//
//        view.color = CheckerColorRed : CheckerColorBlack;
//
//        [self addSubview:view];
//
//        [_checkers addObject:view];
//
//    }

    
    return self;
}

- (void)highlightIndex:(NSInteger)index withColor:(PointHighlightColor)highlightColor
{
    switch (highlightColor) {
        case PointHighlightColorNone:

            break;
        case PointHighlightColorSelected:
            [self unhighlightAll];
            break;
        case PointHighlightColorAllowed:
        case PointHighlightColorForbidden:
            [self willHighlightIndex:index];
            break;
    }

    [self pointViewAtIndex:index].hightlightColor = highlightColor;
}

- (void)unhighlightAll
{
    [self.points bk_each:^(PointView *pointView) {

        pointView.hightlightColor = PointHighlightColorNone;
    }];
}

- (PointView *)pointViewAtIndex:(NSInteger)index
{
    return [self.points bk_match:^BOOL(PointView *pointView) {
        return pointView.pointIndex == index;
    }];
}

- (void)willHighlightIndex:(NSInteger)index
{
    [[self.points bk_reject:^BOOL(PointView *pointView) {

        return pointView.pointIndex == index || pointView.hightlightColor == PointHighlightColorSelected;

    }] bk_each:^(PointView *pointView) {

        pointView.hightlightColor = PointHighlightColorNone;
    }];
}

- (void)placeChecker:(CheckerView *)checker atIndex:(NSInteger)index animated:(BOOL)animated
{
    PointView *pointView = [self pointViewAtIndex:index];

    [checker mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(pointView);
        make.centerY.equalTo(pointView);
    }];
}

- (CheckerView *)topCheckerAtIndex:(NSInteger)index
{
    return [[self.checkers bk_select:^BOOL(CheckerView *checkerView) {

        PointView *pointView = [self pointViewAtIndex:index];

        CGPoint checkerCenter = [pointView convertPoint:checkerView.center
                                               fromView:self];

        return [pointView pointInside:checkerCenter withEvent:nil];
    }] lastObject];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    PointView *pointView = [self.points bk_match:^BOOL(PointView *point) {

        return [point pointInside:[touch locationInView:point]
                        withEvent:event];
    }];

    [self highlightIndex:pointView.pointIndex
               withColor:PointHighlightColorSelected];


    self.selectedCheckerView = [self topCheckerAtIndex:pointView.pointIndex];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint center = [touch locationInView:self];

    self.selectedCheckerView.center = center;

    PointView *pointView = [self.points bk_match:^BOOL(PointView *point) {

        return [point pointInside:[touch locationInView:point]
                        withEvent:event];
    }];

    [self highlightIndex:pointView.pointIndex
               withColor:PointHighlightColorAllowed];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    PointView *pointView = [self.points bk_match:^BOOL(PointView *point) {

        return [point pointInside:[touch locationInView:point]
                        withEvent:event];
    }];

    [self.selectedCheckerView mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.width.and.height.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
        make.center.equalTo(pointView);
    }];

    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];

    self.selectedCheckerView = nil;

    [self unhighlightAll];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"%@\n\n%@", touches, event);
}

#pragma mark - Accessors

- (NSArray *)checkerViews
{
    return [self.checkers copy];
}

@end
