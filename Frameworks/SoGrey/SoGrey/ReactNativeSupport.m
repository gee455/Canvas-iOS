//
//  ReactNativeSupport.m
//  Detox
//
//  Created by Tal Kol on 6/28/16.
//  Copyright © 2016 Wix. All rights reserved.
//

#import "ReactNativeSupport.h"
#import "ReactNativeHeaders.h"

#import "EarlGreyExtensions.h"

#import "WXRunLoopIdlingResource.h"
#import "WXJSDisplayLinkIdlingResource.h"
#import "WXJSTimerObservationIdlingResource.h"
#import "WXAnimatedDisplayLinkIdlingResource.h"

#include <dlfcn.h>
#import "fishhook.h"
@import ObjectiveC;
@import Darwin;

// DTX_CREATE_LOG(ReactNativeSupport);

NSString *const RCTReloadNotification = @"RCTReloadNotification";

static dispatch_queue_t __currentIdlingResourceSerialQueue;

static WXRunLoopIdlingResource* __current_runLoopIdlingResource;
static void (*orig_runRunLoopThread)(id, SEL) = NULL;
static void swz_runRunLoopThread(id self, SEL _cmd)
{
	dispatch_sync(__currentIdlingResourceSerialQueue, ^{
		if(__current_runLoopIdlingResource)
		{
			[[GREYUIThreadExecutor sharedInstance] deregisterIdlingResource:__current_runLoopIdlingResource];
			__current_runLoopIdlingResource = nil;
		}
	
		__current_runLoopIdlingResource = [[WXRunLoopIdlingResource alloc] initWithRunLoop:CFRunLoopGetCurrent()];
		[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:__current_runLoopIdlingResource];
	});
	
	orig_runRunLoopThread(self, _cmd);
}

static WXJSDisplayLinkIdlingResource* __original_displayLinkIdlingResource;
void (*orig_addToRunLoop)(id, SEL, NSRunLoop*) = NULL;
void swz_addToRunLoop(id self, SEL _cmd, NSRunLoop* runloop)
{
	dispatch_sync(__currentIdlingResourceSerialQueue, ^{
		if(__original_displayLinkIdlingResource)
		{
			[[GREYUIThreadExecutor sharedInstance] deregisterIdlingResource:__original_displayLinkIdlingResource];
			__original_displayLinkIdlingResource = nil;
		}
		
		__original_displayLinkIdlingResource = [[WXJSDisplayLinkIdlingResource alloc] initWithDisplayLink:[self valueForKey:@"jsDisplayLink"]];
		[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:__original_displayLinkIdlingResource];
	});
	
	orig_addToRunLoop(self, _cmd, runloop);
}

static NSMutableArray* __observedQueues;

static dispatch_queue_t (*wx_original_dispatch_queue_create)(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr);

dispatch_queue_t wx_dispatch_queue_create(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr)
{
	dispatch_queue_t rv = wx_original_dispatch_queue_create(label, attr);
	
	if(label != NULL && strncmp(label, "com.apple.NSURLSession-work", strlen("com.apple.NSURLSession-work")) == 0)
	{
		[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:[GREYDispatchQueueIdlingResource resourceWithDispatchQueue:rv name:@"com.apple.NSURLSession-work"]];
	}
	
	return rv;
}

static int (*__WX_UIApplicationMain_orig)(int argc, char * _Nonnull * _Null_unspecified argv, NSString * _Nullable principalClassName, NSString * _Nullable delegateClassName);
static int __WX_UIApplicationMain(int argc, char * _Nonnull * _Null_unspecified argv, NSString * _Nullable principalClassName, NSString * _Nullable delegateClassName)
{
	Class cls = NSClassFromString(@"RCTJSCExecutor");
	Method m = NULL;
	if(cls != NULL)
	{
		//Legacy RN
		m = class_getClassMethod(cls, NSSelectorFromString(@"runRunLoopThread"));
	}
	else
	{
		//Modern RN
		cls = NSClassFromString(@"RCTCxxBridge");
		m = class_getClassMethod(cls, NSSelectorFromString(@"runRunLoop"));
		if(m == NULL)
		{
			m = class_getInstanceMethod(cls, NSSelectorFromString(@"runJSRunLoop"));
		}
	}
	
	if(m != NULL)
	{
		orig_runRunLoopThread = (void(*)(id, SEL))method_getImplementation(m);
		method_setImplementation(m, (IMP)swz_runRunLoopThread);
	}
	
	return __WX_UIApplicationMain_orig(argc, argv, principalClassName, delegateClassName);
}

__attribute__((constructor))
void setupForTests()
{
	wx_original_dispatch_queue_create = dlsym(RTLD_DEFAULT, "dispatch_queue_create");
	
	// Rebind symbols dispatch_queue_create to point to our own implementation.
	rebind_symbols((struct rebinding[]){"dispatch_queue_create", wx_dispatch_queue_create, NULL}, 1);
	
	__currentIdlingResourceSerialQueue = dispatch_queue_create("__currentIdlingResourceSerialQueue", NULL);

	Class cls = NSClassFromString(@"RCTModuleData");
	if(cls == nil)
	{
		return;
	}
	
	__observedQueues = [NSMutableArray new];
	
	//Add an idling resource for each module queue.
	Method m = class_getInstanceMethod(cls, NSSelectorFromString(@"setUpMethodQueue"));
	void(*orig_setUpMethodQueue_imp)(id, SEL) = (void(*)(id, SEL))method_getImplementation(m);
	method_setImplementation(m, imp_implementationWithBlock(^(id _self) {
		orig_setUpMethodQueue_imp(_self, NSSelectorFromString(@"setUpMethodQueue"));
		
		dispatch_queue_t queue = object_getIvar(_self, class_getInstanceVariable(cls, "_methodQueue"));
		
		if(queue != nil && [queue isKindOfClass:[NSNull class]] == NO && queue != dispatch_get_main_queue() && [__observedQueues containsObject:queue] == NO)
		{
			NSString* queueName = [[NSString alloc] initWithUTF8String:dispatch_queue_get_label(queue) ?: ""];
			
			[__observedQueues addObject:queue];
			
			// dtx_log_info(@"Adding idling resource for queue: %@", queue);
			
			
			[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:[GREYDispatchQueueIdlingResource resourceWithDispatchQueue:queue name:queueName ?: @"SomeReactQueue"]];
		}
	}));
	
	//Cannot just extern this function - we are not linked with RN, so linker will fail. Instead, look for symbol in runtime.
	dispatch_queue_t (*RCTGetUIManagerQueue)(void) = dlsym(RTLD_DEFAULT, "RCTGetUIManagerQueue");
	
	//Must be performed in +load and not in +setUp in order to correctly catch the ui queue, runloop and display link initialization by RN.
	dispatch_queue_t queue = RCTGetUIManagerQueue();
	[__observedQueues addObject:queue];
	[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:[GREYDispatchQueueIdlingResource resourceWithDispatchQueue:queue name:@"RCTUIManagerQueue"]];
	
	struct rebinding rebindings2[] = {
		{"UIApplicationMain", __WX_UIApplicationMain, (void*)&__WX_UIApplicationMain_orig}
	};
	rebind_symbols(rebindings2, sizeof(rebindings2) / sizeof(rebindings2[0]));
	
	[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:[WXJSTimerObservationIdlingResource new]];
	
	if([WXAnimatedDisplayLinkIdlingResource isAvailable]) {
		[[GREYUIThreadExecutor sharedInstance] registerIdlingResource:[WXAnimatedDisplayLinkIdlingResource new]];
	}
}

@implementation ReactNativeSupport

+ (BOOL) isReactNativeApp
{
    return (NSClassFromString(@"RCTBridge") != nil);
}

+ (void)reloadApp
{
	if(NSClassFromString(@"RCTBridge") == nil)
	{
		//Not RN app - noop.
		return;
	}
	
	id<RN_RCTBridge> bridge = [NSClassFromString(@"RCTBridge") valueForKey:@"currentBridge"];
	
	SEL reqRelSel = NSSelectorFromString(@"requestReload");
	if([bridge respondsToSelector:reqRelSel])
	{
		//Call RN public API to request reload.
		[bridge requestReload];
	}
	else
	{
		//Legacy call to reload RN.
		[[NSNotificationCenter defaultCenter] postNotificationName:RCTReloadNotification
															object:nil
														  userInfo:nil];
	}
}

+ (void)waitForReactNativeLoadWithCompletionHandler:(void (^)(void))handler
{
	__block __weak id observer;
	
	observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"RCTContentDidAppearNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
		
		if(handler)
		{
			handler();
		}
		
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
	}];
}

@end
