//
//  GameData.m
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameData.h"
#import "GameManager.h"

@interface GameData (){
    NSArray *_dataArray;
}

@end

@implementation GameData
-(id)init{
    if (self = [super init]) {
        NSInteger cols = [GameData colCount];
        NSMutableArray *row1Array = [NSMutableArray arrayWithCapacity:cols];
        NSMutableArray *row2Array = [NSMutableArray arrayWithCapacity:cols];
        NSMutableArray *row3Array = [NSMutableArray arrayWithCapacity:cols];
        
        for (int i = 0; i < cols; i++) {
            row1Array[i] = [NSNumber numberWithInt:GamePositionStateEmpty];
            row2Array[i] = [NSNumber numberWithInt:GamePositionStateEmpty];
            row3Array[i] = [NSNumber numberWithInt:GamePositionStateEmpty];
        }
        
        _dataArray = @[row1Array,row2Array,row3Array];
        [_dataArray retain];
    }
    return self;
}
+(NSInteger)rowCount{
    return 3;
}
+(NSInteger)colCount{
    return 8;
}
//所有可能的三子一线的线数组
+(NSArray *)allLines{
    NSMutableArray *result = [NSMutableArray array];
    NSInteger row = [self rowCount];
    NSInteger col = [self colCount];
    //增加所有同一列上的三行
    for (NSInteger c = 0; c < col; c++) {
        NSMutableArray *colLine = [NSMutableArray array];
        for (NSInteger r = 0; r < row; r++) {
            [colLine addObject:[NSValue valueWithCGPoint:CGPointMake(r, c)]];
        }
        [result addObject:colLine];
    }
    //增加同一行上的三列
    for (NSInteger r = 0; r < row; r++) {
        NSMutableArray *rowLine = nil;
        for (NSInteger c = 0; c <= col; c++) {
            if (c % 2 == 0) {
                [rowLine addObject:[NSValue valueWithCGPoint:CGPointMake(r, c % col)]];
                if (c < col) {
                    rowLine = [NSMutableArray array];
                    [result addObject:rowLine];
                    [rowLine addObject:[NSValue valueWithCGPoint:CGPointMake(r, c % col)]];
                }                
            }else{
                [rowLine addObject:[NSValue valueWithCGPoint:CGPointMake(r, c % col)]];
            }
        }
    }
    return result;
}
//顶点数组
+(NSArray *)topPoints{
    NSMutableArray *result = [NSMutableArray array];
    NSInteger row = [self rowCount];
    NSInteger col = [self colCount];
    for (NSInteger r = 0; r < row; r++) {
        for (NSInteger c = 0; c < col; c++) {
            if (r % 2 == 0 && c %2 == 0) {
                [result addObject:[NSValue valueWithCGPoint:CGPointMake(r, c)]];
            }
        }
    }
    return result;
}

//指定点可以一步移动到的点
-(NSArray *)pointsCanReachableBy1StepMoveFromPoint:(CGPoint)point{
    NSMutableArray *result = [NSMutableArray array];
    NSInteger rowCount = [GameData rowCount];
    NSInteger colCount = [GameData colCount];
    NSInteger row = (NSInteger)point.x;
    NSInteger col = (NSInteger)point.y;
    NSInteger temp = row -1;
    CGPoint p2;
    if (temp >= 0) {
        p2 = CGPointMake(temp, col);
        if ([self getPositionStateForPoint:p2] == GamePositionStateEmpty) {
            [result addObject:[NSValue valueWithCGPoint:p2]];
        }
    }
    temp = row +1;
    if (temp < rowCount) {
        p2 = CGPointMake(temp, col);
        if ([self getPositionStateForPoint:p2] == GamePositionStateEmpty) {
            [result addObject:[NSValue valueWithCGPoint:p2]];
        }
    }
    temp = col -1;
    if (temp >= 0) {
        p2 = CGPointMake(row, temp);
        if ([self getPositionStateForPoint:p2] == GamePositionStateEmpty) {
            [result addObject:[NSValue valueWithCGPoint:p2]];
        }
    }
    temp = col +1;
    if (temp < colCount) {
        p2 = CGPointMake(row, temp);
        if ([self getPositionStateForPoint:p2] == GamePositionStateEmpty) {
            [result addObject:[NSValue valueWithCGPoint:p2]];
        }
    }
    return result;
}
//包含指定点的三子一线的线数组
+(NSArray *)linesContainsPoint:(CGPoint)point{
    NSMutableArray *result = [NSMutableArray array];
    NSInteger colCount = [GameData colCount];
    NSInteger row = (NSInteger)point.x;
    NSInteger col = (NSInteger)point.y;
    [result addObject:@[
                        [NSValue valueWithCGPoint:CGPointMake(0, col)],
                        [NSValue valueWithCGPoint:CGPointMake(1, col)],
                        [NSValue valueWithCGPoint:CGPointMake(2, col)]
                        ]];
    NSInteger col2,col3;
    if (col % 2 == 0) {
        col2 = (row+1) % colCount;
        col3 = (row+2) % colCount;
        [result addObject:@[
                            [NSValue valueWithCGPoint:CGPointMake(row, col)],
                            [NSValue valueWithCGPoint:CGPointMake(row, col2)],
                            [NSValue valueWithCGPoint:CGPointMake(row, col3)]
                            ]];
        
        col2 = (colCount + col-1)%colCount;
        col3 = (colCount + col-2)%colCount;
        [result addObject:@[
                            [NSValue valueWithCGPoint:CGPointMake(row, col)],
                            [NSValue valueWithCGPoint:CGPointMake(row, col2)],
                            [NSValue valueWithCGPoint:CGPointMake(row, col3)]
                            ]];
    }else{
        col2 = (col - 1) % colCount;
        col3 = (col + 1) % colCount;
        [result addObject:@[
                            [NSValue valueWithCGPoint:CGPointMake(row, col2)],
                            [NSValue valueWithCGPoint:CGPointMake(row, col)],
                            [NSValue valueWithCGPoint:CGPointMake(row, col3)]
                            ]];
    }
    return result;
}
- (NSArray *)pointsForState:(GamePositionState)targetState {
    NSMutableArray *result = [NSMutableArray array];
    NSInteger row = [GameData rowCount];
    NSInteger col = [GameData colCount];
    for (NSInteger r = 0; r < row; r++) {
        NSArray *rowArray = _dataArray[r];
        for (NSInteger c = 0; c < col; c++) {
            if ([rowArray[c] intValue] == targetState) {
                [result addObject:[NSValue valueWithCGPoint:CGPointMake(r, c)]];
            }
        }
    }
    return result;
}

//空闲点数组
-(NSArray *)emptyPoints{;
    return [self pointsForState:GamePositionStateEmpty];
}
//玩家点数组
-(NSArray *)personPoints{
    return [self pointsForState:GamePositionStatePlayerPerson];
}
//电脑点数组
-(NSArray *)computerPoints{
    return [self pointsForState:GamePositionStatePlayerComputer];
}

-(void)setPositionState:(GamePositionState)state ForPoint:(CGPoint)point{
    NSInteger row = (NSInteger)point.x;
    NSInteger col = (NSInteger)point.y;
    NSMutableArray *rowArray = _dataArray[row];
    rowArray[col] = [NSNumber numberWithInt:state];
}
-(GamePositionState)getPositionStateForPoint:(CGPoint)point{
    NSInteger row = (NSInteger)point.x;
    NSInteger col = (NSInteger)point.y;
    NSArray *rowArray = _dataArray[row];
    return [rowArray[col] intValue];
}
-(void)dealloc{
    [_dataArray release];
    [super dealloc];
}
@end
