#import "cocos2d.h"

@interface PauseUI : CCSprite {
    CCLabelTTF *pause_lives_disp, *pause_bones_disp, *pause_time_disp, *pause_points_disp;
	
	CCLabelTTF *new_high_score_disp;
	
	CCSprite *left_curtain,*right_curtain,*bg_curtain;
	CGPoint left_curtain_tpos,right_curtain_tpos,bg_curtain_tpos;
	BOOL exit_to_gameover_menu;
	CCSprite *ui_stuff;
}

+(PauseUI*)cons;
-(void)update_labels_lives:(NSString*)lives bones:(NSString*)bones time:(NSString*)time score:(NSString*)score  highscore:(BOOL)highscore;
//-(void)update_item_slot;
@end
