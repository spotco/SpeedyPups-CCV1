#import "AskContinueUI.h"
#import "PauseUI.h"
#import "Common.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "GameEngineLayer.h"
#import "UICommon.h"
#import "UILayer.h"
#import "BoneCollectUIAnimation.h"

@implementation AskContinueUI

+(AskContinueUI*)cons {
    return [AskContinueUI node];
}

-(id)init {
    self = [super init];
    
    ccColor4B c = {50,50,50,220};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    CCNode *ask_continue_ui = [CCLayerColor layerWithColor:c width:s.height height:s.width];
    
	playericon = [[CCSprite spriteWithTexture:[Resource get_tex:[Player get_character]]
										 rect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]]
				  pos:[Common screen_pctwid:0.5 pcthei:0.4]];
    [ask_continue_ui addChild:playericon];
    
    [ask_continue_ui addChild:[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
                                                      rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spotlight"]]
                               pos:[Common screen_pctwid:0.5 pcthei:0.6]]];
	
    continue_logo = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
											rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue"]]
					 pos:[Common screen_pctwid:0.5 pcthei:0.8]];
    [ask_continue_ui addChild:continue_logo];
    
    CCMenuItem *yes = [MenuCommon item_from:TEX_UI_INGAMEUI_SS
                                       rect:@"yesbutton"
                                        tar:self sel:@selector(continue_yes)
                                        pos:[Common screen_pctwid:0.3 pcthei:0.4]];
    
    CCMenuItem *no = [MenuCommon item_from:TEX_UI_INGAMEUI_SS
                                      rect:@"nobutton"
                                       tar:self sel:@selector(continue_no)
                                       pos:[Common screen_pctwid:0.7 pcthei:0.4]];
    
    yesnomenu = [CCMenu menuWithItems:yes,no, nil];
    [yesnomenu setPosition:CGPointZero];
    [ask_continue_ui addChild:yesnomenu];
    
    countdown_disp = [Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.575]
                                      color:ccc3(220, 10, 10) fontsize:50 str:@""];
    [ask_continue_ui addChild:countdown_disp];
	
	//continue price pane, below yes button
	continue_price_pane = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_price_bg"]]
									 pos:[Common screen_pctwid:0.3 pcthei:0.25]];
	[continue_price_pane addChild:[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"tinybone"]
								   ] pos:[Common pct_of_obj:continue_price_pane pctx:0.15 pcty:0.25]]];
	[continue_price_pane addChild:[Common cons_label_pos:[Common pct_of_obj:continue_price_pane pctx:0.2 pcty:0.625]
												   color:ccc3(0,0,0)
												fontsize:10
													 str:@"price"]];
	continue_price = [Common cons_label_pos:[Common pct_of_obj:continue_price_pane pctx:0.62 pcty:0.275]
									  color:ccc3(255,0,0)
								   fontsize:18
										str:@"000000"];
	[continue_price_pane addChild:continue_price];
	[ask_continue_ui addChild:continue_price_pane];
	
	//total bones pane, bottom right
	CCSprite *total_bones_pane = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_total_bg"]]
								  pos:[Common screen_pctwid:0.89 pcthei:0.075]];
	[total_bones_pane addChild:[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"tinybone"]
								 ] pos:[Common pct_of_obj:total_bones_pane pctx:0.15 pcty:0.3]]];
	[total_bones_pane addChild:[Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.325 pcty:0.75]
												color:ccc3(0,0,0)
											 fontsize:10
												  str:@"Total Bones"]];
	total_disp = [Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.525 pcty:0.325]
								  color:ccc3(255,0,0)
							   fontsize:20
									str:@"000000"];
	[total_bones_pane addChild:total_disp];
	[ask_continue_ui addChild:total_bones_pane];
	 
    [self addChild:ask_continue_ui];
	bone_anims = [NSMutableArray array];
    
    return self;
}


static BGM_GROUP prev_group;

-(void)start_countdown:(int)cost {
	
	prev_group = [AudioManager get_cur_group];
	[AudioManager playbgm_imm:BGM_GROUP_JINGLE];
	
    countdown_ct = 10;
	mod_ct = 1;
	countdown_disp_scale = 3;
    continue_cost = cost;
	continue_price_pane_vs = 0.01;
	
	[countdown_disp setVisible:YES];
	[yesnomenu setVisible:YES];
	[playericon setPosition:[Common screen_pctwid:0.5 pcthei:0.4]];
	[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]];
	
	curmode = AskContinueUI_COUNTDOWN;
	
    [self schedule:@selector(update:) interval:1/30.0];
    [countdown_disp setString:[NSString stringWithFormat:@"%d",countdown_ct]];
    [continue_price setString:[NSString stringWithFormat:@"%d",cost]];
    [total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_bones]]];
}


-(void)update:(ccTime)delta {
	[Common set_dt:delta];
	mod_ct++;
	
	if (curmode == AskContinueUI_COUNTDOWN) {
		[self update_countdown];
		
	} else if (curmode == AskContinueUI_YES_TRANSFER_MONEY) {
		
		NSMutableArray *toremove = [NSMutableArray array];
		for (UIIngameAnimation *i in bone_anims) {
			[i update];
			if (i.ct <= 0) {
				[self removeChild:i cleanup:YES];
				[toremove addObject:i];
			}
		}
		[bone_anims removeObjectsInArray:toremove];
		[toremove removeAllObjects];
		
		if (bone_anims.count != 0) {
			if (mod_ct % 3 == 0) {
				player_anim_ct++;
				if (player_anim_ct%2==0) {
					[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]];
				} else {
					[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_2"]];
				}
			}
		}
		
		if (continue_cost > 0) {
			int neutotal = total_disp.string.integerValue-countdown_ct;
			int neuprix = continue_price.string.integerValue+countdown_ct;
			continue_cost-=countdown_ct;
			if (mod_ct%10==0) countdown_ct *= 2;
			[continue_price setString:[NSString stringWithFormat:@"%d",neuprix]];
			[total_disp setString:[NSString stringWithFormat:@"%d",neutotal]];
			
			if (mod_ct%2==0) {
				BoneCollectUIAnimation *neuanim = [BoneCollectUIAnimation cons_start:[Common screen_pctwid:0.89 pcthei:0.075]
																				 end:CGPointAdd(playericon.position,ccp(-30,15))];
				[bone_anims addObject:neuanim];
				[self addChild:neuanim];
			}
			
		} else if (bone_anims.count != 0) {
			[continue_price setString:[NSString stringWithFormat:@"%d",actual_next_continue_price]];
			[total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_bones]]];
			
		} else {
			[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]];
			[continue_price setString:[NSString stringWithFormat:@"%d",actual_next_continue_price]];
			[total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_bones]]];
			continue_cost = 10; //used as pause ct now
			[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"run_0"]];
			curmode = AskContinueUI_YES_RUNOUT;
			
		}
		
	} else if (curmode == AskContinueUI_YES_RUNOUT) {
		if (continue_cost > 0) {
			continue_cost--;
			
		} else if (playericon.position.x < [Common SCREEN].width) {
			playericon.position = CGPointAdd(playericon.position, ccp(15,0));
			if (mod_ct % 2 == 0) {
				player_anim_ct = (player_anim_ct + 1) % 4;
				[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character]
																	 idname:[NSString stringWithFormat:@"run_%d",player_anim_ct]]];
			}
			
		} else {
			[AudioManager playbgm_imm:prev_group];
			if ([BGTimeManager get_global_time] == MODE_NIGHT || [BGTimeManager get_global_time] == MODE_DAY_TO_NIGHT) {
				[AudioManager transition_mode2];
			}
			[(UILayer*)[self parent] continue_game];
			[self stop_countdown];
			
		}
	
	}
}

-(void)stop_countdown {
    [self unschedule:@selector(update:)];
}

-(void)continue_no {
    [self stop_countdown];
    [self to_gameover_screen];
}

-(void)continue_yes {
    if ([UserInventory get_current_bones] >= continue_cost) {
		[countdown_disp setVisible:NO];
		[UserInventory add_bones:-continue_cost];
		countdown_ct = 1; //works as transfer rate now
		[yesnomenu setVisible:NO];
		actual_next_continue_price = continue_cost*2;
		[continue_price_pane setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_price_bg_nopoke"]];
		curmode = AskContinueUI_YES_TRANSFER_MONEY;
		
    } else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough bones for a continue!"
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Ok :("
											  otherButtonTitles:nil];
		[alert show];
		curmode = AskContinueUI_COUNTDOWN_PAUSED;
		
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"clique sur bouton:%d",buttonIndex);
	curmode = AskContinueUI_COUNTDOWN;
}

-(void)update_countdown {
	countdown_disp_scale = countdown_disp_scale - (countdown_disp_scale-1)/3;
	[countdown_disp setScale:countdown_disp_scale];
	
	if (continue_price_pane.scale > 1.1) {
		continue_price_pane.scale = 1.1;
		continue_price_pane_vs = -0.01;
		
	} else if (continue_price_pane.scale < 0.9) {
		continue_price_pane.scale = 0.9;
		continue_price_pane_vs = 0.01;
	}
	[continue_price_pane setScale:continue_price_pane.scale + continue_price_pane_vs];
	
	
	if (mod_ct%30==0) {
		countdown_ct--;
		[countdown_disp setString:[NSString stringWithFormat:@"%d",countdown_ct]];
		countdown_disp_scale = 3;
		if (countdown_ct <= 0) {
			[self stop_countdown];
			[self to_gameover_screen];
			return;
		}
	}
}

-(void)to_gameover_screen {
    [(UILayer*)[self parent] to_gameover_menu];
}

@end
