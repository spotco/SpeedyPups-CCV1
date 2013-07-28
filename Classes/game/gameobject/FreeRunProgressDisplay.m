#import "FreeRunProgressDisplay.h"
#import "GEventDispatcher.h"
#import "GameEngineLayer.h"
#import "AutoLevel.h"

@implementation FreeRunProgressDisplay

+(FreeRunProgressDisplay*)cons_pt:(CGPoint)pt {
	return [[FreeRunProgressDisplay node] cons:pt];
}

-(id)cons:(CGPoint)pos {
    [self setPosition:pos];
    active = NO;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > position_.x && player.position.x - position_.x < 1000) {
        active = YES;
		int progress = 0;
		for (GameObject *o in g.game_objects) {
			if ([o class] == [AutoLevel class]) {
				progress = [((AutoLevel*)o) get_freerun_progress];
				break;
			}
		}
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_FREERUN_PROGRESS] add_i1:progress i2:progress]];
    }
}

-(void)reset {
    active = NO;
}

@end