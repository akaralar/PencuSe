//
//  BoardViewController.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardView.h"
#import "Masonry.h"
#import "PointView.h"
#import "CheckerView.h"
#import "BlocksKit.h"

@interface BoardViewController ()

@property (nonatomic) BoardView *boardView;
@property (nonatomic) NSArray *checkers;

@end

@implementation BoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.boardView = [[BoardView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.boardView];

    [self.boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    for (NSInteger i = 0; i < 2; ++i) {

        for (NSInteger j = 0; j < 15; ++j) {

        }
    }
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    NSInteger pointIndex = [self.boardView pointViewIndexForTouch:touch withEvent:event];
    [self.boardView highlightIndex:pointIndex
                         withColor:PointHighlightColorSelected];
    [self.boardView selectTopCheckerAtIndex:pointIndex];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint center = [touch locationInView:self.boardView];
    self.boardView.selectedCheckerView.center = center;

    [self.boardView highlightIndex:[self.boardView pointViewIndexForTouch:touch withEvent:event]
                         withColor:PointHighlightColorAllowed];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    [self.boardView placeChecker:self.boardView.selectedCheckerView
                         atIndex:[self.boardView pointViewIndexForTouch:touch withEvent:event]
                        animated:YES];
    [self.boardView deselectChecker];
    [self.boardView unhighlightAll];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //    NSLog(@"%@\n\n%@", touches, event);
}


@end
