//
//  GameManager.m
//  ThirdChess
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 Gemstar. All rights reserved.
//

#import "GameManager.h"
#import "GameData.h"
#import "GameStepHandler.h"
#import "GameStep1Handler.h"
#import "GameStep2Handler.h"

@interface GameManager (){
    GamePlayer _player;
    GameStep _step;
    GameData *_data;
    GameStepHandler *_handler;
    GameStep1Handler *_handler1;
    GameStep2Handler *_handler2;
}
@property(nonatomic,assign) GamePlayer currentPlayer;
@property(nonatomic,assign) GameStep currentStep;
@end

@implementation GameManager
@synthesize currentPlayer = _player;
@synthesize currentStep = _step;
-(id)init{
    if (self = [super init]) {
        _player = GamePlayerPersorn;
        _step = GameStepPlace;
        _data = [[GameData alloc] init];
        
        _handler1 = [[GameStep1Handler alloc] init];
        _handler1.delegate = self;
        
        _handler2 = [[GameStep2Handler alloc] init];
        _handler2.delegate = self;
        
        _handler = _handler1;
    }
    return self;
}

- (void)handleNextOperation:(GameNextOperation)operation {
    [self changeHandler];
    //检查下一步操作
    if (operation == GameNextOperationChangePlayer) {
        GameNextOperation currentOperation = [_handler currentOperation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate NextOperationChangedTo:currentOperation];
        });
        [self changePlayer];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate NextOperationChangedTo:operation];
        });
    }
}

//指定行列的位置点击
-(void)clickedAtPoint:(CGPoint)point{
    GameNextOperation operation = [_handler clickedAtPoint:point withCurrentPlayer:_player andGameData:_data];
    [self handleNextOperation:operation];
}
-(void)changePlayer{
    if (_player == GamePlayerPersorn) {
        _player = GamePlayerComputer;
        //切换到电脑时,需要由程序自动来操作,然后再更改相应状态
        GameNextOperation operation = [_handler computerAutoDoWithGameData:_data];
        while (operation == GameNextOperationCancel
            || operation == GameNextOperationDelete
            || operation == GameNextOperationMove) {
            operation = [_handler computerAutoDoWithGameData:_data];
        }
        [self handleNextOperation:operation];
    }else{
        _player = GamePlayerPersorn;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate GamePlayerChangedTo:_player];
    });
}
-(void)changeHandler{
    if (!_handler.finished) {
        return;
    }
    if (_handler == _handler1) {
        _handler = _handler2;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //game over
            [self.delegate GameDidFinishedWithWin:_handler2.winner == GamePlayerPersorn];
        });
    }
}
#pragma mark gameStepHandlerDelegate
-(void)positionAtPoint:(CGPoint)point stateChangedFrom:(GamePositionState)oldState to:(GamePositionState)state{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate PositionAtPoint:point hasChangedToState:state];
    });
}
-(void)dealloc{
    [_data release];
    [_handler1 release];
    [_handler2 release];
    [super dealloc];
}
@end
