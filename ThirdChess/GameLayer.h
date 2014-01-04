//
//  GameLayer.h
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "CCLayer.h"
#import "GameManager.h"

@interface GameLayer : CCLayer<CCTouchOneByOneDelegate,GameManagerDelegate>
+(id)scene;
@end
