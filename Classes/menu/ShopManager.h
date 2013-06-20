#import "cocos2d.h"
#import "ShopRecord.h"

@interface ShopManager : CCSprite {
	CCNode *speechbub,*next,*prev,*buy;
	CCLabelTTF *infotitle,*infodesc,*infoprice,*curbones;
	NSArray *itempanes;
	
	ShopTab current_tab;
	NSArray *cur_tab_items;
	int cur_tab_offset;
	ItemInfo *selected_item;
}

+(ShopManager*)cons;

-(void)set_speechbub:(CCNode*)tspeechbub
		   infotitle:(CCLabelTTF*)tinfotitle
			infodesc:(CCLabelTTF*)tinfodesc
			   price:(CCLabelTTF*)tprice
		   itempanes:(NSArray*)titempanes
				next:(CCNode*)tnext
				prev:(CCNode*)tprev
				 buy:(CCNode *)tbuy
		curbonesdisp:(CCLabelTTF*)tcurbones;

-(void)reset;
-(void)pane_next;
-(void)pane_prev;

-(void)tab:(ShopTab)t;

-(void)select_pane:(int)i;

-(void)buy_current;

@end