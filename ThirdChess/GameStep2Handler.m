//
//  GameStep2Handler.m
//  ThirdChess
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameStep2Handler.h"

@interface GameStep2Handler (){
    CGPoint targetPoint;
}

@end

@implementation GameStep2Handler
-(id)init{
    if (self = [super init]) {
        _currentOperation = GameNextOperationSelect;
    }
    return self;
}

//指定行列位置点击通知,如果点击引起的数据改变,则返回true,否则返回false
-(GameNextOperation)clickedAtPoint:(CGPoint)point withCurrentPlayer:(GamePlayer)player andGameData:(GameData*)data{
    GamePositionState state = [data getPositionStateForPoint:point];
    if (_currentOperation == GameNextOperationSelect) {
        if (state == [self getStateForPlayer:player]) {
            self.preSelectedPoint = point;
            _currentOperation = GameNextOperationMove;
            return GameNextOperationMove;
        }
    }else if(_currentOperation == GameNextOperationMove){
        if (state == GamePositionStateEmpty) {
            if ([self canMoveFromPoint:self.preSelectedPoint toPoint:point andGameData:data]) {
                [self moveFromPoint:self.preSelectedPoint toPoint:point andGameData:data];
                _currentOperation = GameNextOperationSelect;
                if ([self isEqualToThreeChessOneLineAtPoint:point andGameData:data]) {
                    _currentOperation = GameNextOperationDelete;
                    return GameNextOperationDelete;
                }
                return GameNextOperationChangePlayer;
            }
        }
    }else if(_currentOperation == GameNextOperationDelete){
        if (state == [self getEnemyStateForPlayer:player]) {
            [data setPositionState:GamePositionStateEmpty ForPoint:point];
            [self.delegate positionAtPoint:point stateChangedFrom:state to:GamePositionStateEmpty];
            _currentOperation = GameNextOperationSelect;
            
            [self isFinishedWithGameData:data];
            
            return GameNextOperationChangePlayer;
        }
    }
    return GameNextOperationStay;
}
//检查是否已经结束
-(BOOL)isFinishedWithGameData:(GameData*)data{
    NSInteger personCount = 0,computerCount = 0;
    NSInteger rowCount = [GameData rowCount];
    NSInteger colCount = [GameData colCount];
    for (NSInteger r = 0; r < rowCount; r++) {
        for (NSInteger c = 0; c < colCount; c++) {
            CGPoint point = CGPointMake(r, c);
            GamePositionState state = [data getPositionStateForPoint:point];
            if (state == GamePositionStatePlayerPerson) {
                personCount++;
            }else if(state == GamePositionStatePlayerComputer){
                computerCount++;
            }
        }
    }
    if (personCount < 3) {
        _finished = true;
        _winner = GamePlayerComputer;
        return true;
    }
    if (computerCount < 3) {
        _finished = true;
        _winner = GamePlayerPersorn;
        return true;
    }
    return false;
}
//是否可以从指定位置移动到新位置
-(BOOL)canMoveFromPoint:(CGPoint)point toPoint:(CGPoint)point2 andGameData:(GameData*)_data{
    NSInteger state = [_data getPositionStateForPoint:point2];
    if (state != GamePositionStateEmpty) {
        return false;
    }
    NSInteger row = (NSInteger)point.x;
    NSInteger col = (NSInteger)point.y;
    
    NSInteger row2 = (NSInteger)point2.x;
    NSInteger col2 = (NSInteger)point2.y;
    
    NSInteger rowSub = row > row2 ? row-row2 : row2-row;
    BOOL isRowRight = rowSub <= 1;
    
    NSInteger colCount = [GameData colCount];
    NSInteger rightCol1 = col + 1;
    NSInteger rightCol2 = col - 1;
    if (rightCol1 < 0) {
        rightCol1 = colCount - 1;
    }
    if (rightCol2 < 0) {
        rightCol2 = colCount - 1;
    }
    rightCol1 = rightCol1 % colCount;
    rightCol2 = rightCol2 % colCount;
    BOOL isColRight = rightCol1 == col2 || rightCol2 == col2 || col == col2;
    
    return isRowRight && isColRight;
}
//移动指定位置到新位置
-(void)moveFromPoint:(CGPoint)point toPoint:(CGPoint)point2 andGameData:(GameData*)_data{
    GamePositionState state = [_data getPositionStateForPoint:point];
    [_data setPositionState:state ForPoint:point2];
    [_data setPositionState:GamePositionStateEmpty ForPoint:point];
    [self.delegate positionAtPoint:point stateChangedFrom:state to:GamePositionStateEmpty];
    [self.delegate positionAtPoint:point2 stateChangedFrom:GamePositionStateEmpty to:state];
}
//电脑人工智能走棋
-(GameNextOperation)computerAutoDoWithGameData:(GameData*)data{
    if (_currentOperation == GameNextOperationSelect) {
        targetPoint = CGPointZero;
        //计算最佳的可移动棋子位置
        NSArray *positions = [data computerPoints];
        //首先,移除掉不能移动的点
        NSMutableArray *moveablePositions = [NSMutableArray array];
        for (NSValue *computerPosition in positions) {
            CGPoint pos = [computerPosition CGPointValue];
            NSArray *reachablePoints = [data pointsCanReachableBy1StepMoveFromPoint:pos];
            if ([reachablePoints count] > 0) {
                [moveablePositions addObject:computerPosition];
            }
        }
        if ([moveablePositions count] == 0) {
            return GameNextOperationChangePlayer;
        }
        //第一规则,移动一步后,可以构成三子一线
        for (NSValue *computerPosition in moveablePositions) {
            CGPoint pos = [computerPosition CGPointValue];
            NSArray *reachablePoints = [data pointsCanReachableBy1StepMoveFromPoint:pos];
            for (NSValue *reachablePosition in reachablePoints) {
                CGPoint reachablePoint = [reachablePosition CGPointValue];
                NSArray *lines = [GameData linesContainsPoint:reachablePoint];
                for (NSArray *linePoints in lines) {
                    NSInteger count = 0;
                    for (NSValue *position in linePoints) {
                        CGPoint temp = [position CGPointValue];
                        if (CGPointEqualToPoint(temp, pos)) {
                            continue;
                        }
                        if ([data getPositionStateForPoint:temp] == GamePositionStatePlayerComputer) {
                            count++;
                        }
                    }
                    if (count == 2) {
                        targetPoint = reachablePoint;
                        return [self clickedAtPoint:pos withCurrentPlayer:GamePlayerComputer andGameData:data];
                    }
                }
            }
        }
        //第二规则,移动后可以阻止对方构成三子一线
        for (NSValue *computerPosition in moveablePositions) {
            CGPoint pos = [computerPosition CGPointValue];
            NSArray *reachablePoints = [data pointsCanReachableBy1StepMoveFromPoint:pos];
            for (NSValue *reachablePosition in reachablePoints) {
                CGPoint reachablePoint = [reachablePosition CGPointValue];
                NSArray *lines = [GameData linesContainsPoint:reachablePoint];
                for (NSArray *linePoints in lines) {
                    NSInteger count = 0;
                    for (NSValue *position in linePoints) {
                        CGPoint temp = [position CGPointValue];
                        if ([data getPositionStateForPoint:temp] == GamePositionStatePlayerPerson) {
                            count++;
                        }
                    }
                    if (count == 2) {
                        targetPoint = reachablePoint;
                        return [self clickedAtPoint:pos withCurrentPlayer:GamePlayerComputer andGameData:data];
                    }
                }
            }
        }
        //第三规则,随机选择一个
        NSInteger index = arc4random() % [moveablePositions count];
        CGPoint point = [[moveablePositions objectAtIndex:index] CGPointValue];
        return [self clickedAtPoint:point withCurrentPlayer:GamePlayerComputer andGameData:data];
    }else if(_currentOperation == GameNextOperationMove){
        //计算当前选择位置可移动到的位置
        //选择点时已经计算好的,则直接移动到指定位置
        if (!CGPointEqualToPoint(CGPointZero, targetPoint)) {
            CGPoint temp = targetPoint;
            targetPoint = CGPointZero;
            return [self clickedAtPoint:temp withCurrentPlayer:GamePlayerComputer andGameData:data];
        }
        //随机选择一个
        NSArray *reachablePoints = [data pointsCanReachableBy1StepMoveFromPoint:self.preSelectedPoint];
        NSInteger index = arc4random() % [reachablePoints count];
        CGPoint point = [[reachablePoints objectAtIndex:index] CGPointValue];
        return [self clickedAtPoint:point withCurrentPlayer:GamePlayerComputer andGameData:data];
    }else if(_currentOperation == GameNextOperationDelete){
        //计算要删除掉的玩家棋子位置
        NSArray *personPositions = [data personPoints];
        //第一规则,删除玩家移动一步后可以构成三子一线的子,优先删除可移动子
        //第二规则,删除玩家移动一步后可以构成三子一线的子,删除一线上的两个子中,除同一线上周围没有玩家的子
        //第三规则,随机选择一个
        NSInteger index = arc4random() % [personPositions count];
        CGPoint point = [[personPositions objectAtIndex:index] CGPointValue];
        return [self clickedAtPoint:point withCurrentPlayer:GamePlayerComputer andGameData:data];
    }
    return GameNextOperationStay;
}
@end
