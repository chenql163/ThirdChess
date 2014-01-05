//
//  BgNode.h
//  ThirdChess
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 Gemstar. All rights reserved.
//

#import "CCNode.h"

@interface BgNode : CCNode
+(BgNode *)node;
-(void)calcPoints;
-(NSDictionary *)positionDic;
@end
