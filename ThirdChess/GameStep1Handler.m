//
//  GameStep1Handler.m
//  ThirdChess
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameStep1Handler.h"

@implementation GameStep1Handler
-(id)init{
    if (self = [super init]) {
        _currentOperation = GameNextOperationPlace;
    }
    return self;
}
//指定行列位置点击通知,如果点击引起的数据改变,则返回true,否则返回false
-(GameNextOperation)clickedAtPoint:(CGPoint)point withCurrentPlayer:(GamePlayer)player andGameData:(GameData*)data{
    GamePositionState state = [data getPositionStateForPoint:point];
    if (_currentOperation == GameNextOperationPlace) {
        if (state == GamePositionStateEmpty) {
            GamePositionState state2 = [self getStateForPlayer:player];
            [data setPositionState:state2 ForPoint:point];
            [self.delegate positionAtPoint:point stateChangedFrom:state to:state2];
            if ([self isEqualToThreeChessOneLineAtPoint:point andGameData:data]) {
                _currentOperation = GameNextOperationCancel;
                return GameNextOperationCancel;
            }
            
            [self isFinishedWithGameData:data];
            
            return GameNextOperationChangePlayer;
        }
    }else if(_currentOperation == GameNextOperationCancel){
        if (state == [self getEnemyStateForPlayer:player]) {
            [data setPositionState:GamePositionStateCancel ForPoint:point];
            [self.delegate positionAtPoint:point stateChangedFrom:state to:GamePositionStateCancel];
            _currentOperation = GameNextOperationPlace;
            
            [self isFinishedWithGameData:data];
            
            return GameNextOperationChangePlayer;
        }
    }
    return GameNextOperationStay;
}
//默认操作,放子
-(GameNextOperation)defaultOperation{
    return GameNextOperationPlace;
}
//检查是否此阶段已经结束,返回true已经结束,false未结束
-(BOOL)isFinishedWithGameData:(GameData*)data{
    //如果所有位置都不是空,则表示已经结束
    BOOL result = true;
    NSInteger rowCount = [GameData rowCount];
    NSInteger colCount = [GameData colCount];
    for (NSInteger r = 0; result && r < rowCount; r++) {
        for (NSInteger c = 0; result && c < colCount; c++) {
            CGPoint point = CGPointMake(r, c);
            GamePositionState state = [data getPositionStateForPoint:point];
            if (state == GamePositionStateEmpty) {
                result = false;
                break;
            }
        }
    }
    if (result) {
        _finished = true;
        [self removeAllCancedWithGameData:data];
    }
    return result;
}
//移除所有标记为取消状态的作废棋子,返回值为已经移除的cgpoint value对象数组,用于界面进行同步更新
-(NSArray*)removeAllCancedWithGameData:(GameData*)_data{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSInteger rowCount = [GameData rowCount];
    NSInteger colCount = [GameData colCount];
    for (int i = 0; i < rowCount; i++) {
        for (int j = 0; j < colCount; j++) {
            CGPoint point = CGPointMake(i, j);
            GamePositionState state = [_data getPositionStateForPoint:point];
            if (state == GamePositionStateCancel) {
                [resultArray addObject:[NSValue valueWithCGPoint:point]];
                [_data setPositionState:GamePositionStateEmpty ForPoint:point];
                [self.delegate positionAtPoint:point stateChangedFrom:state to:GamePositionStateEmpty];
            }
        }
    }
    return resultArray;
}
//电脑人工智能走棋
-(GameNextOperation)computerAutoDoWithGameData:(GameData*)data{
    if (_currentOperation == GameNextOperationPlace) {
        //计算最佳空的位置放子
        NSArray *allLines = [GameData allLines];
        //第一规则,如果已方同一行或列上有两个相同的,并且剩余一个是空的,则放此位置
        for (NSArray *line in allLines) {
            CGPoint emptyPoint;
            NSInteger countEmpty=0,countComputer=0;
            for (NSInteger i = 0; i < [line count]; i++) {
                CGPoint point =[[line objectAtIndex:i] CGPointValue];
                GamePositionState state = [data getPositionStateForPoint:point];
                if (state == GamePositionStatePlayerComputer) {
                    countComputer++;
                }else if(state == GamePositionStateEmpty){
                    countEmpty++;
                    emptyPoint = point;
                }
            }
            if (countEmpty == 1 && countComputer == 2) {
                return [self clickedAtPoint:emptyPoint withCurrentPlayer:GamePlayerComputer andGameData:data];
            }
        }
        //第二规则,如果对方同一行或列上有两个相同的,并且剩余一个是空的,则选择此位置
        for (NSArray *line in allLines) {
            CGPoint emptyPoint;
            NSInteger countEmpty=0,countPerson=0;
            for (NSInteger i = 0; i < [line count]; i++) {
                CGPoint point =[[line objectAtIndex:i] CGPointValue];
                GamePositionState state = [data getPositionStateForPoint:point];
                if (state == GamePositionStatePlayerPerson) {
                    countPerson++;
                }else if(state == GamePositionStateEmpty){
                    countEmpty++;
                    emptyPoint = point;
                }
            }
            if (countEmpty == 1 && countPerson == 2) {
                return [self clickedAtPoint:emptyPoint withCurrentPlayer:GamePlayerComputer andGameData:data];
            }
        }
        //优先选择顶点
        NSArray *topPoints = [GameData topPoints];
        for (NSValue *value in topPoints) {
            CGPoint point = [value CGPointValue];
            if ([data getPositionStateForPoint:point] == GamePositionStateEmpty) {
                return [self clickedAtPoint:point withCurrentPlayer:GamePlayerComputer andGameData:data];
            }
        }
        //随机选择一个
        NSArray *emptyPoints = [data emptyPoints];
        NSInteger index = arc4random() % [emptyPoints count];
        CGPoint point = [[emptyPoints objectAtIndex:index] CGPointValue];
        return [self clickedAtPoint:point withCurrentPlayer:GamePlayerComputer andGameData:data];
    }else if(_currentOperation == GameNextOperationCancel){
        //计算要作废的玩家棋子位置
        NSArray *allLines = [GameData allLines];
        //第一规则,一行上玩家已经有两个子,并且剩余位置是空的
        for (NSArray *line in allLines) {
            CGPoint cancelPoint;
            NSInteger countEmpty=0,countPerson=0;
            for (NSInteger i = 0; i < [line count]; i++) {
                CGPoint point =[[line objectAtIndex:i] CGPointValue];
                GamePositionState state = [data getPositionStateForPoint:point];
                if (state == GamePositionStatePlayerPerson) {
                    countPerson++;
                    cancelPoint = point;
                }else if(state == GamePositionStateEmpty){
                    countEmpty++;
                }
            }
            if (countEmpty == 1 && countPerson == 2) {
                return [self clickedAtPoint:cancelPoint withCurrentPlayer:GamePlayerComputer andGameData:data];
            }
        }
        //优先两顶点中间的位置
        //随机选择一个
        NSArray *playerPoints = [data personPoints];
        NSInteger index = arc4random() % [playerPoints count];
        CGPoint point = [[playerPoints objectAtIndex:index] CGPointValue];
        return [self clickedAtPoint:point withCurrentPlayer:GamePlayerComputer andGameData:data];
    }
    return GameNextOperationStay;
}
@end
