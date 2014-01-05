//
//  GameManager.h
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameEnums.h"
#import "GameStepHandler.h"

@protocol GameManagerDelegate <NSObject>

-(void)GamePlayerChangedTo:(GamePlayer)gamePlayer;
-(void)PositionAtPoint:(CGPoint)point hasChangedToState:(GamePositionState)state;
-(void)NextOperationAtPoint:(CGPoint)point hasChangedTo:(GameNextOperation)nextOperation;
-(void)GameDidFinishedWithWin:(BOOL)isPlayerWin;

@end

@interface GameManager : NSObject<GameStepHandlerDelegate>
@property(nonatomic,assign) id<GameManagerDelegate> delegate;
//指定行列的位置点击
-(void)clickedAtPoint:(CGPoint)point;
@end
