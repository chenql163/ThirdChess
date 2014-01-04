//
//  GameData.h
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameEnums.h"

@interface GameData : NSObject
//总行数
+(NSInteger)rowCount;
//总列数
+(NSInteger)colCount;
//所有可能的三子一线的线数组
+(NSArray *)allLines;
//顶点数组
+(NSArray *)topPoints;
//包含指定点的三子一线的线数组
+(NSArray *)linesContainsPoint:(CGPoint)point;

-(void)setPositionState:(GamePositionState)state ForPoint:(CGPoint)point;
-(GamePositionState)getPositionStateForPoint:(CGPoint)point;
//空闲点数组
-(NSArray *)emptyPoints;
//玩家点数组
-(NSArray *)personPoints;
//电脑点数组
-(NSArray *)computerPoints;
//指定点可以一步移动到的点,并且可以移动到的点的状态必须是空
-(NSArray *)pointsCanReachableBy1StepMoveFromPoint:(CGPoint)point;
@end
