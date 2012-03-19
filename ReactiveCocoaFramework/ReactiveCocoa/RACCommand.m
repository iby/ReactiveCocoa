//
//  RACCommand.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RACCommand.h"
#import "RACCommand+Private.h"
#import "RACObserver.h"

@interface RACCommand ()
@property (nonatomic, copy) BOOL (^canExecuteBlock)(id value);
@property (nonatomic, strong) RACSubject *executeSubject;
@end


@implementation RACCommand

- (id)init {
	self = [super init];
	if(self == nil) return nil;
	
	self.canExecute = YES;
	self.executeSubject = [RACSubject subject];
	
	return self;
}


#pragma mark RACObservable

- (RACDisposable *)subscribe:(id<RACObserver>)observer {
	return [self.executeSubject subscribe:observer];
}


#pragma mark API

@synthesize canExecute;
@synthesize canExecuteBlock;
@synthesize executeSubject;

+ (id)command {
	return [[self alloc] init];
}

+ (id)commandWithCanExecute:(BOOL (^)(id value))canExecuteBlock execute:(void (^)(id value))executeBlock {
	RACCommand *command = [self command];
	if(executeBlock != NULL) [command.executeSubject subscribeNext:executeBlock];
	command.canExecuteBlock = canExecuteBlock;
	return command;
}

+ (id)commandWithCanExecuteObservable:(id<RACObservable>)canExecuteObservable execute:(void (^)(id value))executeBlock {
	RACCommand *command = [self commandWithCanExecute:NULL execute:executeBlock];
	
	[canExecuteObservable subscribe:[RACObserver observerWithNext:^(id x) {
		command.canExecute = [x boolValue];
	} error:NULL completed:NULL]];
	
	return command;
}

- (BOOL)canExecute:(id)value {
	if(self.canExecuteBlock != NULL) {
		return self.canExecuteBlock(value);
	}
	
	return self.canExecute;
}

- (void)execute:(id)value {
	[self.executeSubject sendNext:value];
}

@end
