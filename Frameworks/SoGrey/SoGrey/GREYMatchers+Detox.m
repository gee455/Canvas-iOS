//
//  GREYMatchers+Detox.m
//  Detox
//
//  Created by Tal Kol on 10/7/16.
//  Copyright © 2016 Wix. All rights reserved.
//

#import "GREYMatchers+Detox.h"
#import "EarlGreyExtensions.h"
#import "ReactNativeSupport.h"

@implementation GREYMatchers (Detox)

+ (id<GREYMatcher>)detoxMatcherForText:(NSString *)text
{
	Class RCTTextViewClass = NSClassFromString(@"RCTText") ?: NSClassFromString(@"RCTTextView");
    if (!RCTTextViewClass)
    {
        return grey_text(text);
    }
    
    // in React Native RCTText the accessibilityLabel is hardwired to be the text inside
    return grey_anyOf(grey_text(text),
                      grey_allOf(grey_kindOfClass(RCTTextViewClass),
                                 hasProperty(@"accessibilityLabel", text),
								 nil),
					  nil);
    
}

//all(label, not_decendant(all(RCTText, with-label))

+ (id<GREYMatcher>)detox_matcherForAccessibilityLabel:(NSString *)label {
	if (![ReactNativeSupport isReactNativeApp])
	{
		return  [self matcherForAccessibilityLabel:label];
	}
	else
	{
		Class RCTTextViewClass = NSClassFromString(@"RCTText") ?: NSClassFromString(@"RCTTextView");
		return grey_allOf(grey_accessibilityLabel(label),
						  grey_not(grey_descendant(grey_allOf(grey_kindOfClass(RCTTextViewClass),
															  grey_accessibilityLabel(label),
															  nil))),
						  nil);
	}
	
}

+ (id<GREYMatcher>)detoxMatcherForScrollChildOfMatcher:(id<GREYMatcher>)matcher
{
    // find scroll views in a more robust way, either the original matcher already points to a UIScrollView
    // and if it isn't look for a child under it that is a UIScrollView
    return grey_anyOf(grey_allOf(grey_anyOf(grey_kindOfClass([UIScrollView class]),
                                            grey_kindOfClass([UIWebView class]),
											nil),
                                 matcher,
								 nil),
                      grey_allOf(grey_kindOfClass([UIScrollView class]),
                                 grey_ancestor(matcher),
								 nil),
					  nil);
}

+ (id<GREYMatcher>)detoxMatcherAvoidingProblematicReactNativeElements:(id<GREYMatcher>)matcher
{
    Class RN_RCTScrollView = NSClassFromString(@"RCTScrollView");
    if (!RN_RCTScrollView)
    {
        return matcher;
    }
    
    // RCTScrollView is problematic because EarlGrey's visibility matcher adds a subview and this causes a RN assertion
    //  solution: if we match RCTScrollView, switch over to matching its contained UIScrollView
    
	return grey_anyOf(grey_allOf(matcher,
								 grey_not(grey_kindOfClass(RN_RCTScrollView)),
								 nil),
					  grey_allOf(grey_kindOfClass([UIScrollView class]),
                                 grey_ancestor(grey_allOf(matcher,
														  grey_kindOfClass(RN_RCTScrollView),
														  nil)),
								 nil),
                      nil);
}

+ (id<GREYMatcher>)detoxMatcherForBoth:(id<GREYMatcher>)firstMatcher and:(id<GREYMatcher>)secondMatcher
{
    return grey_allOf(firstMatcher, secondMatcher, nil);
}

+ (id<GREYMatcher>)detoxMatcherForBoth:(id<GREYMatcher>)firstMatcher andAncestorMatcher:(id<GREYMatcher>)ancestorMatcher
{
    return grey_allOf(firstMatcher, grey_ancestor(ancestorMatcher), nil);
}

+ (id<GREYMatcher>)detoxMatcherForBoth:(id<GREYMatcher>)firstMatcher andDescendantMatcher:(id<GREYMatcher>)descendantMatcher
{
    return grey_allOf(firstMatcher, grey_descendant(descendantMatcher), nil);
}

+ (id<GREYMatcher>)detoxMatcherForNot:(id<GREYMatcher>)matcher
{
    return grey_not(matcher);
}

+ (id<GREYMatcher>)detoxMatcherForClass:(NSString *)aClassName
{
    Class klass = NSClassFromString(aClassName);
    return grey_kindOfClass(klass);
}

@end
