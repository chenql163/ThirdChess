//
//  GameLayer.m
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameLayer.h"
#import "MainLayer.h"
#import "BgNode.h"

#define TagForGameOverLayer 120

@interface GameLayer (){
    CCSpriteBatchNode *personBatch;
    CCSpriteBatchNode *computerBatch;
    CGPoint startPoint;
    GameManager *gameManager;
    NSMutableDictionary *spritDic;
    dispatch_queue_t gameQueue;
    CCLabelTTF *placeLabel,*cancelLabel,*selectLabel,*moveLabel,*deleteLabel;
    NSDictionary *positions;
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
        computer.position = ccpAdd(personLabel.position, ccp(personLabel.contentSize.width+computer.contentSize.width, 0));
        [computerBatch addChild:computer];
        CCLabelTTF *computerLabel = [CCLabelTTF labelWithString:@"电脑" fontName:@"Arial" fontSize:24];
        computerLabel.color = ccc3(0, 0, 0);
        computerLabel.position = ccpAdd(computer.position, ccp(computer.contentSize.width*0.5+computerLabel.contentSize.width, 0));
        [self addChild:computerLabel z:0];
        
        CCLabelTTF *promptLabel = [CCLabelTTF labelWithString:@"操作提示:" fontName:@"Arial" fontSize:16];
        promptLabel.position = ccpAdd(person.position, ccp(0+promptLabel.contentSize.width * 0.5-person.contentSize.width, -person.contentSize.height - 10));
        promptLabel.color = ccc3(0, 0, 0);
        [self addChild:promptLabel z:0];
        
        placeLabel = [CCLabelTTF labelWithString:@"请选择要放子的位置" fontName:@"Arial" fontSize:16];
        placeLabel.color = ccc3(0, 255, 0);
        placeLabel.position = ccpAdd(promptLabel.position, ccp(promptLabel.contentSize.width*0.5+placeLabel.contentSize.width*0.5, 0));
        [self addChild:placeLabel z:0];
        cancelLabel = [CCLabelTTF labelWithString:@"请选择要标记为删除的对方棋子" fontName:@"Arial" fontSize:16];
        cancelLabel.color = placeLabel.color;
        cancelLabel.position = ccpAdd(promptLabel.position, ccp(promptLabel.contentSize.width * 0.5 + cancelLabel.contentSize.width * 0.5, 0));
        [self addChild:cancelLabel z:0];
        selectLabel = [CCLabelTTF labelWithString:@"请选择要移动的棋子" fontName:@"Arial" fontSize:16];
        selectLabel.color = placeLabel.color;
        selectLabel.position = ccpAdd(promptLabel.position, ccp(promptLabel.contentSize.width * 0.5 + selectLabel.contentSize.width * 0.5, 0));
        [self addChild:selectLabel z:0];
        moveLabel = [CCLabelTTF labelWithString:@"请选择要移动到的位子" fontName:@"Arial" fontSize:16];
        moveLabel.color = placeLabel.color;
        moveLabel.position = ccpAdd(promptLabel.position, ccp(promptLabel.contentSize.width*0.5+moveLabel.contentSize.width*0.5, 0));
        [self addChild:moveLabel z:0];
        deleteLabel = [CCLabelTTF labelWithString:@"请选择要删除的对方棋子" fontName:@"Arial" fontSize:16];
        deleteLabel.color = placeLabel.color;
        deleteLabel.position = ccpAdd(promptLabel.position, ccp(promptLabel.contentSize.width*.5+deleteLabel.contentSize.width*0.5, 0));
        [self addChild:deleteLabel z:0];
        
        
//        CCSprite *bgChess = [CCSprite spriteWithFile:@"bgForThree.png"];
//        bgChess.position = ccp(winSize.width * 0.5, bgChess.contentSize.height * 0.5);
//        [self addChild:bgChess z:0];
        BgNode *bgNode = [BgNode node];
        float y1 = bgNode.contentSize.height * 0.5;
        float y2 = (promptLabel.position.y - promptLabel.contentSize.height*0.5) * 0.5;
        float y = min(y1, y2);
        bgNode.position = ccp(bgNode.contentSize.width * 0.5, winSize.height-y);
        CCLOG(@"winsize:%@,promptlabel position:%@,bgnode position:%@",NSStringFromCGSize(winSize),NSStringFromCGPoint(promptLabel.position),NSStringFromCGPoint(bgNode.position));
        [bgNode calcPoints];
        positions = bgNode.positionDic;
        [self addChild:bgNode z:0];
        
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
        NSArray *keys = [positions allKeys];
        for (NSValue *key in keys) {
            CGRect rect = [[positions objectForKey:key] CGRectValue];
            if (CGRectContainsPoint(rect, endPoint)) {
                CGPoint point = [key CGPointValue];
                dispatch_async(gameQueue, ^{
                    [gameManager clickedAtPoint:point];
                });
                break;
            }
        }
    }
}
-(void)onEnter{
    [self showPromptLabel:placeLabel];
    [super onEnter];
}
#pragma mark gameManagerDelegate
-(CGPoint)positionForPoint:(CGPoint)point{
    NSArray *keys = [positions allKeys];
    for (NSValue *key in keys) {
        CGPoint target = [key CGPointValue];
        if (CGPointEqualToPoint(point, target)) {
            CGRect rect = [[positions objectForKey:key] CGRectValue];
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
-(void)showPromptLabel:(CCLabelTTF *)label{
    placeLabel.visible = false;
    cancelLabel.visible = false;
    selectLabel.visible = false;
    moveLabel.visible = false;
    deleteLabel.visible = false;
    label.visible = true;
}
-(void)blinkSpritsAtPoint:(CGPoint)point{
    NSArray *spritArray = [self spritArrayAtPoint:point];
    for (CCSprite *sprit in spritArray) {
        id blind = [CCBlink actionWithDuration:1 blinks:4];
        id ever = [CCRepeatForever actionWithAction:blind];
        [sprit runAction:ever];
    }
}
-(void)unblinkSprits{
    NSArray *keys = [spritDic allKeys];
    for (NSValue *key in keys) {
        NSArray *spritArray = [spritDic objectForKey:key];
        for (CCSprite *sprit in spritArray) {
            [sprit stopAllActions];
            sprit.visible = true;
        }
    }
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
-(void)NextOperationAtPoint:(CGPoint)point hasChangedTo:(GameNextOperation)nextOperation{
    [self unblinkSprits];
    switch (nextOperation) {
        case GameNextOperationMove:
            [self showPromptLabel:moveLabel];
            [self blinkSpritsAtPoint:point];
            break;
        case GameNextOperationStay:
            break;
        case GameNextOperationPlace:
            [self showPromptLabel:placeLabel];
            break;
        case GameNextOperationCancel:
            [self showPromptLabel:cancelLabel];
            break;
        case GameNextOperationChangePlayer:
            break;
        case GameNextOperationDelete:
            [self showPromptLabel:deleteLabel];
            break;
        case GameNextOperationSelect:
            [self showPromptLabel:selectLabel];
            break;
    }
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
    [gameManager release];
    [spritDic release];
    dispatch_release(gameQueue);
    [super dealloc];
}
@end
