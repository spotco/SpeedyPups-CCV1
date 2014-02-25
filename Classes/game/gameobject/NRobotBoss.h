#import "GameObject.h"

@class NRobotBossBody;
@class NCatBossBody;

typedef enum NRobotBossMode {
	NRobotBossMode_TOREMOVE,
	NRobotBossMode_CAT_IN_RIGHT1,
	NRobotBossMode_CAT_TAUNT_RIGHT1,
	NRobotBossMode_CAT_ROBOT_IN_RIGHT1,
	
	NRobotBossMode_CHOOSING,

	NRobotBossMode_ATTACK_WALLROCKETS_IN,
	NRobotBossMode_ATTACK_WALLROCKETS,
	NRobotBossMode_ATTACK_CHARGE_LEFT,
	
	NRobotBossMode_ATTACK_STREAMHOMING_IN,
	NRobotBossMode_ATTACK_STREAMHOMING,
	NRobotBossMode_ATTACK_CHARGE_RIGHT
} NRobotBossMode;

@interface NRobotBoss : GameObject {
	GameEngineLayer __unsafe_unretained *g;
	
	NRobotBossBody *robot_body;
	NCatBossBody *cat_body;
	
	CGPoint cat_body_rel_pos;
	CGPoint robot_body_rel_pos;
	CGPoint cape_item_rel_pos;
	
	float delay_ct;
	float tmp_ct;
	int pattern_ct;
	
	float groundlevel;
	
	NRobotBossMode cur_mode;
	
	
}

+(NRobotBoss*)cons_with:(GameEngineLayer*)g;

@end