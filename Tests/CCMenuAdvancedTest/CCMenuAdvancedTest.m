/*
 * CCMenuAdvanced Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Stepan Generalov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCMenuAdvanced.h"
#import "CCMenuAdvancedTest.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCMenuAdvancedTestLayer)

@implementation CCMenuAdvancedTestLayer

enum nodeTags
{
	// Tags to distinguish what button was pressed.
	kItemVerticalTest,
	kItemHorizontalTest,
	kItemPriorityTest,
	
	// Tag to get children in updateForScreenReshape
	kMenu,
	kAdvice,
	
	// Vertical Test Node Tags
	kBackButtonMenu,
	kWidget,
};

- (id) init
{
	if ( (self=[super init]) )
	{
		// Create advice label.		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Choose the test." fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Menu should be at the the screen center." fontName:@"Marker Felt" fontSize:24];
		label2.anchorPoint = ccp(0.5f, 1);
		label2.position = ccp(0.5f * label.contentSize.width, 0);
		[label addChild: label2];
		[self addChild: label z:1 tag: kAdvice];
		
		
		// Prepare Menu Items.
		CCMenuItemSprite *verticalTestItem = 
			[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"verticalTestButton.png"]
									selectedSprite: [CCSprite spriteWithFile: @"verticalTestButton.png"]
											target: self
										  selector: @selector(itemPressed:)];
		
		CCMenuItemSprite *horizontalTestItem = 
		[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"horizontalTestButton.png"]
								selectedSprite: [CCSprite spriteWithFile: @"horizontalTestButton.png"]
										target: self
									  selector: @selector(itemPressed:)];
		
		CCMenuItemSprite *priorityTestItem = 
		[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"priorityTestButton.png"]
								selectedSprite: [CCSprite spriteWithFile: @"priorityTestButton.png"]
										target: self
									  selector: @selector(itemPressed:)];
		
		// Distinguish Normal/Selected State of Menu Items.
		[verticalTestItem.selectedImage setColor:ccGRAY];
		[horizontalTestItem.selectedImage setColor:ccGRAY];
		[priorityTestItem.selectedImage setColor:ccGRAY];
			
		// Set Menu Items Tags.
		verticalTestItem.tag = kItemVerticalTest;
		horizontalTestItem.tag = kItemHorizontalTest;
		priorityTestItem.tag = kItemPriorityTest;
		
		// Create & Add Menu.
		CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:verticalTestItem, horizontalTestItem, priorityTestItem, nil];
		[menu alignItemsHorizontallyWithPadding: 0.33 * verticalTestItem.contentSize.width ];
		[self addChild: menu z:0 tag: kMenu];
		
		// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
		menu.debugDraw = YES;
#endif
		
		// Do initial layout.
		[self updateForScreenReshape];
	}
	
	return self;
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	// Position label at top.
	CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag: kAdvice];
	label.anchorPoint = ccp(0.5f,1);
	label.position = ccp( 0.5f * s.width, 0.9f * s.height);
	
	// Position Menu at Center.
	CCMenuAdvanced *menu = (CCMenuAdvanced *)[self getChildByTag: kMenu];
	menu.anchorPoint = ccp(0.5f,0.5f);
	menu.position = ccp( 0.5f * s.width, 0.5f * s.height);
}

- (void) changeSceneWithLayer: (CCLayer *) layer
{														
	CCScene *scene = [CCScene node];							
	[scene addChild: layer];						
	[[CCDirector sharedDirector] replaceScene: scene];										
}

- (void) itemPressed: (CCNode *) item
{
	switch (item.tag) {
		case kItemVerticalTest:
			[self changeSceneWithLayer:[CCMenuAdvancedVerticalTestLayer node]];
			break;
		case kItemHorizontalTest:
			[self changeSceneWithLayer:[CCMenuAdvancedHorizontalTestLayer node]];
			break;
		case kItemPriorityTest:
			NSLog(@"priority pressed");
			break;
		default:
			break;
	}
}

@end

@implementation CCMenuAdvancedVerticalTestLayer

- (id) init
{
	if ( (self = [super init]) )
	{		
		// Create advice label.		
		CCLabelTTF  *label = [self adviceLabel];
		[self addChild: label z:1 tag: kAdvice];
		
		// Create back button menu item.
		CCMenuItemSprite *backMenuItem = 
				[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile:@"b1.png"]
										selectedSprite: [CCSprite spriteWithFile:@"b1.png"]
												target: self
											  selector: @selector(backPressed)
						 ];
		[backMenuItem.selectedImage setColor: ccGRAY];
		CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:backMenuItem, nil];
		[self addChild:menu z:0 tag: kBackButtonMenu];
		
		// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
		menu.debugDraw = YES;
#endif
		
		// Bind keyboard for mac.
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		menu.escapeDelegate = backMenuItem;
#endif
		
		// Create vertical scroll widget.
		CCNode *widget = [self widget];
		[self addChild: widget z: 0 tag: kWidget];		
		
		// Do initial layout.
		[self updateForScreenReshape];	
	}
	
	return self;
}


- (void) updateForScreenReshape
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	// Position label at top.
	CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag: kAdvice];
	label.anchorPoint = ccp(0.5f,1);
	label.position = ccp( 0.5f * s.width, 0.9f * s.height);
	
	// Position back button at the top-left corner.
	CCMenuAdvanced *menu = (CCMenuAdvanced *)[self getChildByTag: kBackButtonMenu];
	menu.anchorPoint = ccp(0, 1);
	menu.position = ccp(0, s.height);
	
	[self updateWidget];
}

// Go back to the default ExtensionTest Layer.
- (void) backPressed
{	
	[[CCDirector sharedDirector] replaceScene: [ExtensionTest scene]];
}

#pragma mark Vertical Scroll Widget

- (NSArray *) menuItemsArray
{	
	NSArray *array = [NSArray arrayWithObjects:
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level #1" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level #2" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level #3" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level +10050" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level #nil" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level Kill" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level Kill Bill" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Whatever..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Oh, commoooooOON!!!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Fork you!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"FORK YOU!!!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"...." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"WAAAZAAAAAAAA!!! =)" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  nil  ];
	
	return array;
}

- (CCLabelTTF *) adviceLabel
{
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Vertical Test." fontName:@"Marker Felt" fontSize:24];
	CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Scrollable menu should be at the the left." fontName:@"Marker Felt" fontSize:24];
	label2.anchorPoint = ccp(0.5f, 1);
	label2.position = ccp(0.5f * label.contentSize.width, 0);
	[label addChild: label2];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"(Controls: up, down, enter, esc)" fontName:@"Marker Felt" fontSize:24];
	label3.anchorPoint = ccp(0.5f, 1);
	label3.position = ccp(0.5f * label2.contentSize.width, 0);
	[label2 addChild: label3];
#endif
	
	return label;
}

- (CCNode *) widget
{
	// Get Menu Items
	NSArray *menuItems = [self menuItemsArray];
	
	// Prepare Menu
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: nil];	
	for (CCMenuItem *item in menuItems)
		[menu addChild: item];	
	
	// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
	menu.debugDraw = YES;
#endif
	
	// Setup Menu Alignment
	[menu alignItemsVerticallyWithPadding: 5 bottomToTop: NO]; //< also sets contentSize and keyBindings on Mac
	menu.isRelativeAnchorPoint = YES;	
	
	return menu;
}

- (void) updateWidget
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	CCMenuAdvanced *menu = (CCMenuAdvanced *) [self getChildByTag:kWidget]; 
	
	//widget	
	menu.anchorPoint = ccp(0.5f, 1);
	menu.position = ccp(winSize.width / 4, winSize.height);
	
	menu.scale = MIN ((winSize.width / 2.0f) / menu.contentSize.width, 0.75f );
	
	menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f), 
								   25.0f, 
								   [menu boundingBox].size.width, 
								   winSize.height - 50.0f );
	
	[menu fixPosition];	
}

- (void) itemPressed: (CCNode *) sender
{
	NSLog(@"CCMenuAdvancedVerticalTestLayer#itemPressed: %@", sender);
}

@end

@implementation CCMenuAdvancedHorizontalTestLayer


- (CCLabelTTF *) adviceLabel
{
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Horizontal Test." fontName:@"Marker Felt" fontSize:24];
	CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Scrollable menu should be at the center." fontName:@"Marker Felt" fontSize:24];
	label2.anchorPoint = ccp(0.5f, 1);
	label2.position = ccp(0.5f * label.contentSize.width, 0);
	[label addChild: label2];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"(Controls: left, right, enter, esc)" fontName:@"Marker Felt" fontSize:24];
	label3.anchorPoint = ccp(0.5f, 1);
	label3.position = ccp(0.5f * label2.contentSize.width, 0);
	[label2 addChild: label3];
#endif
	
	return label;
}

- (CCNode *) widget
{	
	// Prepare Menu.
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: nil];	
	
	// Prepare menu items.
	for (int i = 0; i <= 31; ++i)
	{
		// Create menu item.
		CCMenuItemSprite *item = 
		[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"blankTestButton.png"]
								selectedSprite: [CCSprite spriteWithFile: @"blankTestButton.png"]
										target: self
									  selector: @selector(itemPressed:)];
		
		// Add order number.
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", i] fontName:@"Marker Felt" fontSize:24];
		label.anchorPoint = ccp(0.5f, 0.5f);
		label.position =  ccp(0.5f * item.contentSize.width, 0.5f* item.contentSize.height);
		[item addChild: label z: 1];
		
		// Distinguish normal/selected state of menu items.
		[item.selectedImage setColor:ccGRAY];
		
		// Add it.
		[menu addChild: item];
	}
	
	// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
	menu.debugDraw = YES;
#endif
	
	// Setup Menu Alignment.
	[menu alignItemsHorizontally]; //< also sets contentSize and keyBindings on Mac		
	
	return menu;
}

- (void) updateWidget
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	CCMenuAdvanced *menu = (CCMenuAdvanced *) [self getChildByTag:kWidget]; 
	
	// Initial position.	
	menu.anchorPoint = ccp(0.5f, 0.5f);
	menu.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
	
	menu.scale = MIN ((winSize.height / 2.0f) / menu.contentSize.height, 0.75f );
	
	menu.boundaryRect = CGRectMake( 25.0f, 
								   0.5f * winSize.height - 0.5f * [menu boundingBox].size.height ,
								   winSize.width - 50.0f,
								   [menu boundingBox].size.height );
	
	// Show first menuItem (scroll max to the left).
	menu.position = ccp(menu.contentSize.width / 2.0f, 0.5f * winSize.height);
	
	[menu fixPosition];	
}

@end




#ifdef __NOT_USED

@implementation DemoMenu

- (id) init
{
	if ( (self = [super init]) )
	{
		_backgroundLayer = [CCLayerColor layerWithColor: ccc4(0x86, 0xbd, 0xb7, 255) ];
		[self addChild:_backgroundLayer];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"allDemoElements.plist"
																 textureFile: @"allDemoElements.png" ];
		
		_cornerSil = [CCSprite spriteWithSpriteFrameName:@"rightBigLogo.png"];
		[self addChild: _cornerSil];
		
		_nameLogo = [CCSprite spriteWithSpriteFrameName:@"topCaption.png"];
		[self addChild: _nameLogo];
		
		_widget = [DemoMenuWidget menuWidgetWithReversedOrder: NO];
		[self addChild: _widget];
		
		_widget2 = [DemoMenuWidget menuWidgetWithReversedOrder: YES];
		[self addChild: _widget2];
		
		// update positions and scalex of children
		[self updateForScreenReshape];
		
	}
	
	return self;
}

- (void) onExit
{
	[self removeAllChildrenWithCleanup:YES];
	[super onExit];
}

- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[super dealloc];
}


- (void) updateForScreenReshape
{
	// size of window
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	// background to fit the window
	[_backgroundLayer setContentSize: winSize];
	
	// caption must be not more that 1/5 window height, and must not be overscaled
	_nameLogo.scale = (winSize.height / 5.0f) / ([_nameLogo contentSize].height);
	_nameLogo.scale = MIN(_nameLogo.scale, 1.0f);
	
	// position caption at top center
	_nameLogo.anchorPoint = ccp(0.5f, 1.0f );
	_nameLogo.position = ccp(winSize.width / 2.0f, winSize.height);	
	
	// BG silhouette must fit on screen in height and 1/2 of screen in width
	_cornerSil.scale = (winSize.width / 2.0f) / [_cornerSil contentSize].width;
	_cornerSil.scale = MIN(_cornerSil.scale, winSize.height /  [_cornerSil contentSize].height);
	_cornerSil.scale = MIN(_cornerSil.scale, 1.0f);
	
	
	// positoin BG Silhouette
	_cornerSil.anchorPoint = ccp(1,0);
	_cornerSil.position = ccp(winSize.width, 0); 
	
	// active Size is space that left for menu after caption
	CGSize activeSize = CGSizeMake( winSize.width, 
								   winSize.height - _nameLogo.scale * [_nameLogo contentSize].height);
	
	// scale and position menu widget
	_widget2.scale = _widget.scale = (winSize.width) / [_widget contentSize].width;
	_widget2.scale = _widget.scale = MIN(_widget.scale, activeSize.height / [_widget contentSize].height);
	_widget2.scale = _widget.scale = MIN(_widget.scale, 1.0f);
	_widget2.anchorPoint = _widget.anchorPoint = ccp(0.5f, 0);
	_widget.position = ccp(winSize.width / 2.0f, 0);
	_widget2.position = ccp(winSize.width / 2.0f, [_widget boundingBox].size.height);
}

@end



@implementation DemoMenuWidget 

+ (id) menuWidgetWithReversedOrder: (BOOL) rightToLeft
{
	return [[[self alloc] initWithReversedOrder:rightToLeft] autorelease];
}

- (id) initWithReversedOrder: (BOOL) rightToLeft
{
	if ( (self = [super init]) )
	{
		// Be sure to have needed Sprites Frames loaded
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"allDemoElements.plist"
																 textureFile: @"allDemoElements.png" ];
		
		// Get all universal sprites
		CCSprite *dummyButton1 = [CCSprite spriteWithSpriteFrameName:@"dummyButton1.png"];
		CCSprite *dummyButton1Selected = [CCSprite spriteWithSpriteFrameName:@"dummyButton1.png"];
		dummyButton1Selected.opacity = 128;
		
		CCSprite *dummyButton2 = [CCSprite spriteWithSpriteFrameName:@"dummyButton2.png"];
		CCSprite *dummyButton2Selected = [CCSprite spriteWithSpriteFrameName:@"dummyButton2.png"];
		dummyButton2Selected.opacity = 128;
		
		CCSprite *listButton = [CCSprite spriteWithSpriteFrameName:@"listButton.png"];
		CCSprite *listButtonSelected = [CCSprite spriteWithSpriteFrameName:@"listButton.png"];	
		listButtonSelected.opacity = 128;
		

		
		// Prepare Universal Menu Items
		CCMenuItemSprite *dummyMenuItem1 = 
		[CCMenuItemSprite itemFromNormalSprite: dummyButton1
								selectedSprite: dummyButton1Selected
										target: self
									  selector: @selector(dummyButton1Pressed)
		 ];
		
		CCMenuItemSprite *dummyMenuItem2 = 
		[CCMenuItemSprite itemFromNormalSprite: dummyButton2
								selectedSprite: dummyButton2Selected
										target: self
									  selector: @selector(dummyButton2Pressed)
		 ];
		
		CCMenuItemSprite *listMenuItem = 
		[CCMenuItemSprite itemFromNormalSprite: listButton
								selectedSprite: listButtonSelected
										target: self
									  selector: @selector(listButtonPressed)
		 ];
		
		
		// Create CCMenuAdvanced
		CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: dummyMenuItem1, dummyMenuItem2, listMenuItem, nil];
		menu.anchorPoint = ccp(0,0);
		menu.position = ccp(0,0);
		
		[menu alignItemsHorizontallyWithPadding:50.0f leftToRight:!rightToLeft];
		self.contentSize = menu.contentSize;

		[self addChild: menu];
		
	}
	
	return self;
}

- (void) dummyButton1Pressed
{
	NSLog(@"dummy button 1 pressed");
}

- (void) dummyButton2Pressed
{
	NSLog(@"dummy button 2 (TWO) pressed");
}

- (void) listButtonPressed
{
	// change to DemoMenu2
	// It's better to change scene in GameManager, but here i use this for fast code
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// Add Demo Menu
	DemoMenu2 *menu = [DemoMenu2 node];
	menu.anchorPoint = menu.position = ccp(0,0);
	
	// add layer as a child to scene
	[scene addChild: menu];
	
	// change scene
	[[CCDirector sharedDirector] replaceScene: scene];
}

@end


@implementation GenericDemoMenu

- (id) init
{
	if ( (self = [super init]) )
	{
		_background = [CCColorLayer layerWithColor:ccc4(0, 0, 0, 255)];
		[self addChild:_background z:DEMO_MENU_Z_BACKGROUND];
		
		// Ensure that we have needed Sprite Frame 
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"allDemoElements.plist"
																 textureFile: @"allDemoElements.png" ];
		
		// Create back button
		CCSprite *backButton = [CCSprite spriteWithSpriteFrameName:@"backButton.png"];
		CCSprite *backButtonSelected = [CCSprite spriteWithSpriteFrameName:@"backButtonSelected.png"];
		_backMenuItem = [CCMenuItemSprite itemFromNormalSprite: backButton
												selectedSprite: backButtonSelected
														target: self
													  selector: @selector(backPressed)
						 ];
		CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:_backMenuItem, nil];
		
		// Bind keyboard for mac
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		menu.escapeDelegate = _backMenuItem;
#endif
		menu.anchorPoint = ccp(0,0);
		menu.position = ccp(0,0);
		[self addChild:menu z:DEMO_MENU_Z_BACK_BUTTON];
		
		// Setup Caption
		_caption = [CCSprite spriteWithSpriteFrameName:[self captionSpriteFrameName]];
		[self addChild:_caption z: DEMO_MENU_Z_CAPTION];
	}
	
	return self;
}

- (void) onExit
{
	[self removeAllChildrenWithCleanup:YES];
	[super onExit];
}

- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[super dealloc];
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	_backMenuItem.anchorPoint = ccp(0.0f,1.0f);
	_backMenuItem.position = ccp(0, winSize.height);
	
	[_background setContentSize: winSize ];
	
	_caption.anchorPoint = ccp(0.5, 1);
	_caption.position = ccp(winSize.width / 2.0f, winSize.height);	
	
}

- (NSString *) captionSpriteFrameName
{
	NSAssert(NO, @"DemoMenuWidget#captionSpriteFrameName called! This method should be reimplemented.");
	return nil;
}

- (void) backPressed
{	
	// nothing here
}

@end

@interface DemoMenu2 (Private)

// update leftSideWidget behavior
- (void) updateWidget;

// returns new autoreleased CCSprite for right side
- (CCSprite *) rightSideSilSprite;

// returns new autoreleased widget for left side - must be reimplemented in subclasses
- (CCNode *) leftSideWidget;


@end


@implementation DemoMenu2

- (id) init
{
	if ( (self = [super init]) ) 
	{
		// Load Sprites
		_sil = [self rightSideSilSprite];
		if (_sil)
			[self addChild: _sil z: DEMO_MENU_Z_COVER];				
		
		if ( (_widget = [self leftSideWidget]) )
			[self addChild: _widget z: DEMO_MENU_Z_CONTENT];
		
		//borders		
		_topBorder = [CCSprite spriteWithSpriteFrameName:@"FaderTop.png"];
		_bottomBorder = [CCSprite spriteWithSpriteFrameName:@"FaderBottom.png"];
		[self addChild: _topBorder z: DEMO_MENU_Z_BORDERS];
		[self addChild: _bottomBorder z: DEMO_MENU_Z_BORDERS];
		[[_topBorder texture] setAliasTexParameters];
		
		// update positions and scalex of children
		[self updateForScreenReshape];
	}
	
	return self;
}


- (void) updateForScreenReshape
{
	[super updateForScreenReshape];
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CGSize activeSize = CGSizeMake(winSize.width, winSize.height - _caption.contentSize.height);
	
	// sil
	if (_sil)
	{
		_sil.scale = activeSize.height / _sil.contentSize.height;
		_sil.scale = MIN(_sil.scale, (winSize.width / 2.0f) / _sil.contentSize.width);
		_sil.scale = MIN(_sil.scale, 1.0f);
		
		_sil.anchorPoint = ccp(1, 0.5f);
		_sil.position = ccp(winSize.width, activeSize.height / 2.0f);
	}
	
	[self updateWidget];
	
	//borders
	_topBorder.scaleX = winSize.width / _topBorder.contentSize.width;
	_topBorder.anchorPoint = ccp(0,1);
	_topBorder.position = ccp(0, winSize.height);
	
	_bottomBorder.scaleX = winSize.width / _bottomBorder.contentSize.width;
	_bottomBorder.anchorPoint = ccp(0,0);
	_bottomBorder.position = ccp(0, 0);
}

- (CCSprite *) rightSideSilSprite
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"allDemoElements.plist" 
															 textureFile:@"allDemoElements.png" ];
	
	return [CCSprite spriteWithSpriteFrameName:@"listBigLogoRight.png"];
}

- (NSString *) captionSpriteFrameName
{
	return @"listMenuCaption.png";
}

- (NSArray *) menuItemsArray
{	
	NSArray *array = [NSArray arrayWithObjects:
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level #1" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level #2" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level #3" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level +10050" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level #nil" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level Kill" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level Kill Bill" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Whatever..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Oh, commoooooOON!!!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Fork you!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"FORK YOU!!!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"...." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"WAAAZAAAAAAAA!!! =)" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  nil  ];
	
	return array;
}


- (CCNode *) leftSideWidget
{
	// Get Menu Items
	NSArray *menuItems = [self menuItemsArray];
	
	// Prepare Menu
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: nil];	
	for (CCMenuItem *item in menuItems)
		[menu addChild: item];		
	
	// Setup Menu Alignment
	[menu alignItemsVerticallyWithPadding: 5 bottomToTop: NO]; //< also sets contentSize and keyBindings on Mac
	menu.isRelativeAnchorPoint = YES;	
	
	return menu;
}

- (void) updateWidget
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CGSize activeSize = CGSizeMake(winSize.width, winSize.height - _caption.contentSize.height);
	
	CCMenuAdvanced *menu = (CCMenuAdvanced *) _widget; 
	
	//widget	
	menu.anchorPoint = ccp(0.5f, 1);
	menu.position = ccp(winSize.width / 4, winSize.height - _caption.contentSize.height);
	
	menu.scale = MIN ((winSize.width / 2.0f) / _widget.contentSize.width, 0.75f );
	
	menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f), 
								   [_bottomBorder boundingBox].size.height, 
								   [menu boundingBox].size.width,
								   (activeSize.height - [_bottomBorder boundingBox].size.height));
	
	[menu fixPosition];	
}


- (void) itemPressed: (CCNode *) sender
{
	NSLog(@"DemoMenu2#itemPressed: %@", sender);
}

// I like to use GameDirector for calls from menus (such as buttons pressed)
// but here is too simple example or this, so i will just import DemoMenu to DemoMenu2.h
// and change scene right from here
//
// But it's recommended to have something like GameManager class, and 
// all Scene changes must be called only from there
- (void) backPressed
{	
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// Add Demo Menu
	DemoMenu *menu = [DemoMenu node];
	menu.anchorPoint = menu.position = ccp(0,0);
	
	// add layer as a child to scene
	[scene addChild: menu];
	
	// change scene
	[[CCDirector sharedDirector] replaceScene: scene];
}

@end

#endif
