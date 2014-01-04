//
//  GameLayer.m
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameLayer.h"
#import "MainLayer.h"

#define TagForGameOverLayer 120

@interface GameLayer (){
    CCSpriteBatchNode *personBatch;
    CCSpriteBatchNode *computerBatch;
    CGPoint startPoint;
    NSArray *positions;
    GameManager *gameManager;
    NSMutableDictionary *spritDic;
    dispatch_queue_t gameQueue;
}

@end

@implementation GameLayer
+(id)scene{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [GameLayer node];
    [scene addChild:layer];
    
    return scene;
}
-(id)init{
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLayerColor *bgColor = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:bgColor z:-1];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"喊三棋" fontName:@"Arial" fontSize:32];
        title.color = ccc3(100, 0, 0);
        title.position = ccp(winSize.width * 0.5, winSize.height-title.contentSize.height);
        [self addChild:title z:0];
        
        personBatch = [CCSpriteBatchNode batchNodeWithFile:@"sprit1ForThree.png"];
        [self addChild:personBatch z:1];
        computerBatch = [CCSpriteBatchNode batchNodeWithFile:@"sprit2ForThree.png"];
        [self addChild:computerBatch z:1];
        
        CCSprite *person = [CCSprite spriteWithFile:@"sprit1ForThree.png"];
        person.position = ccp(20+person.contentSize.width*0.5, title.position.y - person.contentSize.height-20);
        [personBatch addChild:person z:1];
        CCLabelTTF *personLabel = [CCLabelTTF labelWithString:@"玩家" fontName:@"Arial" fontSize:24];
        personLabel.color = ccc3(0, 0, 0);
        personLabel.position = ccpAdd(person.position, ccp(person.contentSize.width*0.5+personLabel.contentSize.width, 0));
        [self addChild:personLabel z:0];
        
        CCSprite *computer = [CCSprite spriteWithFile:@"sprit2ForThree.png"];
        computer.position = ccpAdd(person.position, ccp(0, -person.contentSize.height - 10));
        [computerBatch addChild:computer];
        CCLabelTTF *computerLabel = [CCLabelTTF labelWithString:@"电脑" fontName:@"Arial" fontSize:24];
        computerLabel.color = ccc3(0, 0, 0);
        computerLabel.position = ccpAdd(computer.position, ccp(computer.contentSize.width*0.5+computerLabel.contentSize.width, 0));
        [self addChild:computerLabel z:0];
        
        CCSprite *bgChess = [CCSprite spriteWithFile:@"bgForThree.png"];
        bgChess.position = ccp(winSize.width * 0.5, bgChess.contentSize.height * 0.5);
        [self addChild:bgChess z:0];
        
        positions = [@[
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(71, 207, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 0)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(145, 207, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 1)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(212, 207, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 2)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(212, 138, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 3)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(212, 74, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 4)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(145, 74, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 5)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(71, 74, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 6)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(71, 138, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(0, 7)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(30, 251, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 0)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(145, 251, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 1)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(246, 251, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 2)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(246, 138, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 3)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(246, 30, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 4)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(145, 30, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 5)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(30, 30, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 6)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(30, 138, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(1, 7)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(-3, 287, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 0)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(145, 287, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 1)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(290, 287, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 2)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(290, 138, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 3)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(290, 0, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 4)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(145, 0, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 5)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(-3, 0, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 6)]},
                       @{@"rect":[NSValue valueWithCGRect:CGRectMake(-3, 138, 36, 36)],
                         @"point":[NSValue valueWithCGPoint:ccp(2, 7)]}
                       ] retain];
        
        self.touchMode = kCCTouchesOneByOne;
        self.touchEnabled = true;
        
        gameQueue = dispatch_queue_create("com.kevin.gameQueue",NULL );
        
        gameManager = [[GameManager alloc] init];
        gameManager.delegate = self;
        spritDic = [[NSMutableDictionary alloc] initWithCapacity:24];
    }
    return self;
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    startPoint = [[CCDirector sharedDirector] convertTouchToGL:touch];
    return true;
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint endPoint = [[CCDirector sharedDirector] convertTouchToGL:touch];
    if (CGPointEqualToPoint(startPoint, endPoint)) {
        //判断点击的位置
        for (NSDictionary *dic in positions) {
            CGRect rect = [[dic objectForKey:@"rect"] CGRectValue];
            if (CGRectContainsPoint(rect, endPoint)) {
                CGPoint point = [[dic objectForKey:@"point"] CGPointValue];
                dispatch_async(gameQueue, ^{
                    [gameManager clickedAtPoint:point];
                });
                break;
            }
        }
    }
}
#pragma mark gameManagerDelegate
-(CGPoint)positionForPoint:(CGPoint)point{
    for (NSDictionary *dic in positions) {
        CGPoint target = [[dic objectForKey:@"point"] CGPointValue];
        if (CGPointEqualToPoint(point, target)) {
            CGRect rect = [[dic objectForKey:@"rect"] CGRectValue];
            return ccp(CGRectGetMidX(rect), CGRectGetMidY(rect));
        }
    }
    return CGPointZero;
}
-(NSMutableArray *)spritArrayAtPoint:(CGPoint)point{
    NSValue *key =[NSValue valueWithCGPoint:point];
    NSMutableArray *array = [spritDic objectForKey:key];
    if (!array) {
        array = [NSMutableArray array];
        [spritDic setObject:array forKey:key];
    }
    return array;
}
-(void)showCancelAtPoint:(CGPoint)point{
    CCSprite *cancel = [CCSprite spriteWithFile:@"Cancel.png"];
    cancel.position = [self positionForPoint:point];
    [self addChild:cancel z:2];
    
    NSMutableArray *spritArray = [self spritArrayAtPoint:point];
    [spritArray addObject:cancel];
}
-(void)showPersonAtPoint:(CGPoint)point{
    CCSprite *person = [CCSprite spriteWithFile:@"sprit1ForThree.png"];
    person.position = [self positionForPoint:point];
    [personBatch addChild:person];
    
    NSMutableArray *spritArray = [self spritArrayAtPoint:point];
    [spritArray addObject:person];
}
-(void)showComputerAtPoint:(CGPoint)point{
    CCSprite *computer = [CCSprite spriteWithFile:@"sprit2ForThree.png"];
    computer.position = [self positionForPoint:point];
    [computerBatch addChild:computer];
    
    NSMutableArray *spritArray = [self spritArrayAtPoint:point];
    [spritArray addObject:computer];
}
-(void)clearSpritsAtPoint:(CGPoint)point{
    NSMutableArray *spritArray = [self spritArrayAtPoint:point];
    for (CCSprite *sprit in spritArray) {
        [sprit removeFromParentAndCleanup:YES];
    }
    [spritArray removeAllObjects];
}
-(void)GamePlayerChangedTo:(GamePlayer)gamePlayer{
}
-(void)PositionAtPoint:(CGPoint)point hasChangedToState:(GamePositionState)state{
    switch (state) {
        case GamePositionStateCancel:
            [self showCancelAtPoint:point];
            break;
        case GamePositionStatePlayerPerson:
            [self showPersonAtPoint:point];
            break;
        case GamePositionStatePlayerComputer:
            [self showComputerAtPoint:point];
            break;
        case GamePositionStateEmpty:
            [self clearSpritsAtPoint:point];
            break;
    }
}
-(void)NextOperationChangedTo:(GameNextOperation)nextOperation{
    
}
-(void)GameDidFinishedWithWin:(BOOL)isPlayerWin{
    NSString *msg = isPlayerWin ? @"你赢了" : @"你输了";
    CCLabelTTF *gameOver = [CCLabelTTF labelWithString:msg fontName:@"Arial" fontSize:48];
    gameOver.color = ccc3(0, 0, 0);
    CGSize winSize = [CCDirector sharedDirector].winSize;
    gameOver.position = ccp(winSize.width * 0.5, winSize.height + gameOver.contentSize.height);
    [self addChild:gameOver z:10 tag:TagForGameOverLayer];
    
    id moveTo = [CCMoveTo actionWithDuration:0.8 position:ccp(winSize.width * 0.5, winSize.height*0.5)];
    id scale = [CCScaleBy actionWithDuration:.5 scale:2];
    id scale2 = [scale reverse];
    id delay = [CCDelayTime actionWithDuration:1.5];
    id callback = [CCCallBlock actionWithBlock:^(void){
        CCScene *mainScene = [MainLayer scene];
        [[CCDirector sharedDirector] replaceScene:mainScene];
    }];
    id action = [CCSequence actions:moveTo,scale,scale2,delay,callback, nil];
    [gameOver runAction:action];
    
}
-(void)dealloc{
    [positions release];
    [gameManager release];
    [spritDic release];
    dispatch_release(gameQueue);
    [super dealloc];
}
@end
