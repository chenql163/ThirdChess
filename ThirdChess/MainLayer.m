//
//  MainLayer.m
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "MainLayer.h"
#import "GameLayer.h"

@implementation MainLayer
+(id)scene{
    CCScene *scene = [CCScene node];
    
    CCLayer *layer = [MainLayer node];
    [scene addChild:layer];
    
    return scene;
}
-(id)init{
    if (self = [super init]) {
        CCLayerColor *bg = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:bg];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"喊三棋" fontName:@"Arial" fontSize:64];
        title.color = ccc3(100, 0, 0);
        CGSize winSize = [CCDirector sharedDirector].winSize;
        title.position = ccp(winSize.width * 0.5, winSize.height * 0.8);
        [self addChild:title];
        
        CCLabelTTF *newGameLabel = [CCLabelTTF labelWithString:@"新游戏" fontName:@"Arial" fontSize:32];
        newGameLabel.color = ccc3(0, 0, 0);
        CCMenuItemLabel *newGameItem = [CCMenuItemLabel itemWithLabel:newGameLabel block:^(id sender){
            CCScene *gameScene = [GameLayer scene];
            [[CCDirector sharedDirector] replaceScene:gameScene];
            
        }];
        CCLabelTTF *resumeGameLabel = [CCLabelTTF labelWithString:@"继续游戏" fontName:@"Arial" fontSize:32];
        resumeGameLabel.color = ccc3(0, 0, 0);
        CCMenuItemLabel *resumeGameItem = [CCMenuItemLabel itemWithLabel:resumeGameLabel block:^(id sender){
            
        }];
        CCMenu *menu = [CCMenu menuWithItems:newGameItem,resumeGameItem, nil];
        menu.position = ccp(winSize.width * 0.5, winSize.height * 0.4);
        [menu alignItemsVerticallyWithPadding:20];
        [self addChild:menu];
    }
    return self;
}
@end
