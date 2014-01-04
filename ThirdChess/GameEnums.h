//
//  GameEnums.h
//  ThirdChess
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import <Foundation/Foundation.h>

//游戏玩家
typedef NS_ENUM(NSInteger, GamePlayer) {
    GamePlayerPersorn = 1,    //玩家
    GamePlayerComputer         //电脑
};
//游戏阶段
typedef NS_ENUM(NSInteger, GameStep) {
    GameStepPlace = 1,      //放置棋子阶段
    GameStepMove            //移动棋子阶段
};
//指定位置的状态
typedef NS_ENUM(NSInteger, GamePositionState) {
    GamePositionStateEmpty = 0,//位置为空
    GamePositionStatePlayerPerson,//玩家1
    GamePositionStatePlayerComputer,//玩家2
    GamePositionStateCancel//取消状态,将在放置完成后移除所有此类状态位置上的棋子
};
//下一步操作状态
typedef NS_ENUM(NSInteger, GameNextOperation) {
    GameNextOperationPlace = 1, //下一步是在空位置放置当前玩家的棋子
    GameNextOperationCancel,    //下一步是选择要作废对方的棋子
    GameNextOperationDelete,    //下一步是选择要移除对方的棋子
    GameNextOperationMove,       //下一步是选择要移动到的空位置
    GameNextOperationChangePlayer,//下一步是更改玩家
    GameNextOperationStay,         //保持当前状态不变,主要是在当前操作无效时返回此状态
    GameNextOperationSelect         //选择要操作的棋子
};

@interface GameEnums : NSObject

@end
