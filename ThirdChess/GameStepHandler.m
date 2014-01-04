//
//  GameStepHandler.m
//  ThirdChess
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameStepHandler.h"

@implementation GameStepHandler
-(id)init{
    if (self = [super init]) {
        _currentOperation = GameNextOperationStay;
        _finished = false;
    }
    return self;
}
//获取指定位置上能构成行列满三的座标值
-(NSArray*)pointsInLineAtPoint:(CGPoint)point{
    NSInteger colCount = [GameData colCount];
    NSMutableArray *lines = [NSMutableArray array];
    NSInteger row = (NSInteger)point.x;
    NSInteger col = (NSInteger)point.y;
    //同一列上的直线
    NSArray *colLine = @[[NSValue valueWithCGPoint:CGPointMake(0, col)],
                         [NSValue valueWithCGPoint:CGPointMake(1, col)],
                         [NSValue valueWithCGPoint:CGPointMake(2, col)]];
    [lines addObject:colLine];
    
    NSInteger k = 0 - col % 2;
    //同一行上的直线1
    NSArray *rowLine1 = @[[NSValue valueWithCGPoint:CGPointMake(row, col+k % colCount)],
                          [NSValue valueWithCGPoint:CGPointMake(row, (col+k+1) % colCount)],
                          [NSValue valueWithCGPoint:CGPointMake(row, (col+k+2) % colCount)]];
    [lines addObject:rowLine1];
    if (k == 0) {
        //位于顶点位置,还要检查另一边的同一行上是否全相等
        NSInteger c1 = col -1;
        NSInteger c2 = col -2;
        if (c1 < 0) {
            c1 = 7;
            c2 = 6;
        }
        NSArray *rowLine2 = @[[NSValue valueWithCGPoint:CGPointMake(row, col)],
                              [NSValue valueWithCGPoint:CGPointMake(row, c1)],
                              [NSValue valueWithCGPoint:CGPointMake(row, c2)]];
        [lines addObject:rowLine2];
    }
    return lines;
}
//检查指定位置放置棋子后,是否满足满三的条件
-(BOOL)isEqualToThreeChessOneLineAtPoint:(CGPoint)point andGameData:(GameData*)data{
    NSArray *lines = [self pointsInLineAtPoint:point];
    for (NSArray *points in lines) {
        CGPoint p0 = [[points objectAtIndex:0] CGPointValue];
        CGPoint p1 = [[points objectAtIndex:1] CGPointValue];
        CGPoint p2 = [[points objectAtIndex:2] CGPointValue];
        if ([data getPositionStateForPoint:p0] == [data getPositionStateForPoint:p1] &&
            [data getPositionStateForPoint:p1] == [data getPositionStateForPoint:p2]) {
            return true;
        }
    }
    return false;
}
//获取指定玩家对应的位置状态
-(GamePositionState)getStateForPlayer:(GamePlayer)player{
    if (player == GamePlayerPersorn) {
        return GamePositionStatePlayerPerson;
    }
    return GamePositionStatePlayerComputer;
}
//获取指定玩家敌对玩家对应的位置状态
-(GamePositionState)getEnemyStateForPlayer:(GamePlayer)player{
    if (player == GamePlayerPersorn) {
        return GamePositionStatePlayerComputer;
    }
    return GamePositionStatePlayerPerson;
}
//指定行列位置点击通知,如果点击引起的数据改变,则返回true,否则返回false
-(GameNextOperation)clickedAtPoint:(CGPoint)point withCurrentPlayer:(GamePlayer)player andGameData:(GameData*)data{
    return GameNextOperationStay;
}
//当前点击完成后下一步的操作
-(GameNextOperation)defaultOperation{
    return GameNextOperationStay;
}
//当前游戏步骤是否已经结束
-(BOOL)finished{
    return _finished;
}
//整个游戏结束后的胜利者
-(GamePlayer)winner{
    return _winner;
}
//电脑人工智能走棋
-(GameNextOperation)computerAutoDoWithGameData:(GameData*)data{
    return GameNextOperationStay;
}
@end
