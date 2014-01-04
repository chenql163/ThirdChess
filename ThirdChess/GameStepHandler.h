//
//  GameStepHandler.h
//  ThirdChess
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameEnums.h"
#import "GameData.h"

@protocol GameStepHandlerDelegate <NSObject>

-(void)positionAtPoint:(CGPoint)point stateChangedFrom:(GamePositionState)oldState to:(GamePositionState)state;

@end

@interface GameStepHandler : NSObject{
    GameNextOperation _currentOperation;
    BOOL _finished;
    GamePlayer _winner;
}
@property(nonatomic,assign) id<GameStepHandlerDelegate> delegate;
//获取指定位置上能构成行列满三的座标值
-(NSArray*)pointsInLineAtPoint:(CGPoint)point;
//检查指定位置放置棋子后,是否满足满三的条件
-(BOOL)isEqualToThreeChessOneLineAtPoint:(CGPoint)point andGameData:(GameData*)data;
//获取指定玩家敌对玩家对应的位置状态
-(GamePositionState)getEnemyStateForPlayer:(GamePlayer)player;
//获取指定玩家对应的位置状态
-(GamePositionState)getStateForPlayer:(GamePlayer)player;
//指定行列位置点击通知,如果点击引起的数据改变,则返回true,否则返回false
-(GameNextOperation)clickedAtPoint:(CGPoint)point withCurrentPlayer:(GamePlayer)player andGameData:(GameData*)data;
//当前游戏步骤下的默认操作
-(GameNextOperation)defaultOperation;
//当前游戏步骤是否已经结束
-(BOOL)finished;
//整个游戏结束后的胜利者
-(GamePlayer)winner;
//电脑人工智能走棋
-(GameNextOperation)computerAutoDoWithGameData:(GameData*)data;
@end
