#import "MinionRobot.h"
#import "GameEngineLayer.h"

@implementation MinionRobot

+(MinionRobot*)cons_x:(float)x y:(float)y {
	return [[MinionRobot node] cons_x:x y:y];
}

-(void)autolevel_set_position:(CGPoint)pt {
	starting_pos = pt;
	[self setPosition:pt];
}

-(id)cons_x:(float)x y:(float)y {
	body = [CCSprite node];
	bodyimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOT]
									 rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];
				
	[bodyimg setScale:0.83];
	[body setPosition:[Common pct_of_obj:bodyimg pctx:0 pcty:0.5]];
	[body addChild:bodyimg];
	[self addChild:body];
	
	[self setPosition:ccp(x,y)];
	[self autolevel_set_position:ccp(x,y)];
	self.active = YES;
	[self setVisible:YES];
	
	vx = 0;
	vy = 0;
	current_island = NULL;
	
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!has_shadow) {
       [g add_gameobject:[ObjectShadow cons_tar:self]];
        has_shadow = YES;
    }
	
	if (current_island == NULL) {
		CGPoint ins;
		Island *ins_isl;
		if ([self has_hit_ground:g rtv_ins:&ins rtv_isl:&ins_isl]) {
			current_island = ins_isl;
			[self setPosition:ins];
			vx = 0;
			vy = 0;
			
		} else {
			[self setPosition:CGPointAdd(position_, ccp(vx,vy))];
			vx = 0;
			vy -=0.5;
		
		}
		
	} else if (player.position.x < position_.x && current_island != NULL && !busted) {
        vx = 0;
		vy = float_random(10, 11);
		current_island = NULL;
		[self setPosition:CGPointAdd(position_, ccp(vx,vy))];
		
    }
    
    if (busted) {
        if (current_island == NULL) {
            bodyimg.rotation+=25;
        }
        return;
    } else {
        [self animmode_angry];
    }
    
    if (player.current_island == NULL && player.vy <= 0 && [Common hitrect_touch:[self get_hit_rect] b:[player get_jump_rect]]  && !player.dead) {
        busted = YES;
        vy = -ABS(vy);
        [self animmode_dead];
        
        int ptcnt = arc4random_uniform(4)+4;
        for(float i = 0; i < ptcnt; i++) {
            [g add_particle:[BrokenMachineParticle cons_x:position_.x
                                                        y:position_.y
                                                       vx:float_random(-5, 5)
                                                       vy:float_random(-3, 10)]];
        }
        
        [AudioManager playsfx:SFX_BOP];
        
        [MinionRobot player_do_bop:player g:g];
    
    } else if ((player.dashing || [player is_armored]) && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]  && !player.dead) {
        busted = YES;
        vy = -ABS(vy);
        [self animmode_dead];
        
        int ptcnt = arc4random_uniform(4)+4;
        for(float i = 0; i < ptcnt; i++) {
            [g add_particle:[BrokenMachineParticle cons_x:position_.x
                                                            y:position_.y
                                                           vx:float_random(-5, 5) 
                                                           vy:float_random(-3, 10)]];
        }
        [AudioManager playsfx:SFX_ROCKBREAK];
        
        [MinionRobot player_do_bop:player g:g];
        
    } else if (!player.dead && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]  && !player.dead) {
        [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
        [DazedParticle cons_effect:g tar:player time:40];
        [AudioManager playsfx:SFX_HIT];

    }
}

-(BOOL)has_hit_ground:(GameEngineLayer*)g rtv_ins:(CGPoint*)rtins rtv_isl:(Island**)rtisl {
    line_seg mv = [Common cons_line_seg_a:position_ b:CGPointAdd(position_, ccp(vx,vy))];
    for (Island* i in g.islands) {
        line_seg li = [i get_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:li b:mv];
        if (ins.x != [Island NO_VALUE]) {
			*rtins = ins;
			*rtisl = i;
            return YES;
        }
    }
    return NO;
}

+(void)player_do_bop:(Player*)player g:(GameEngineLayer*)g {
    player.vy = 8;
    [player remove_temp_params:g];
    [[player get_current_params] add_airjump_count];
    player.dashing = NO;
}

-(void)reset {
    [super reset];
    [self setPosition:starting_pos];
    [self animmode_normal];
    busted = NO;
	bodyimg.rotation = 0;
}

-(HitRect)get_hit_rect {
	return [Common hitrect_cons_x1:position_.x-20 y1:position_.y wid:50 hei:80];
}

-(void)animmode_normal {[bodyimg setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];}
-(void)animmode_angry {[bodyimg setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot_angry"]];}
-(void)animmode_dead {[bodyimg setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot_dead"]];}
-(int)get_render_ord {return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];}

@end
