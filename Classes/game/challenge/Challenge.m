#import "Challenge.h"
#import "DataStore.h"

@implementation ChallengeInfo

@synthesize map_name;
@synthesize ct;
@synthesize type,reward;

+(ChallengeInfo*)cons_name:(NSString *)map_name type:(ChallengeType)type ct:(int)ct reward:(int)rw {
    ChallengeInfo *i = [[ChallengeInfo alloc] init];
    [i setMap_name:map_name];
    [i setType:type];
    [i setCt:ct];
    [i setReward:rw];
    return i;
}

-(NSString*)to_string {
    ChallengeInfo *cc = self;
    if (cc.type == ChallengeType_COLLECT_BONES) {
        return [NSString stringWithFormat:@"Collect at least %d bones in one run.",cc.ct];
        
    } else if (cc.type == ChallengeType_TIMED) {
        return [NSString stringWithFormat:@"Complete this level in %@ or less.",@"0:00"];
        
    } else if (cc.type == ChallengeType_FIND_SECRET) {
        return [NSString stringWithFormat:@"Find at least %d secrets.",cc.ct];
        
    } else {
        return @"ERROR";
    }
}

@end



@implementation ChallengeRecord

static NSArray* _CHALLENGES;

+(void)initialize {
    _CHALLENGES = @[
        [ChallengeInfo cons_name:@"tutorial_breakrocks" type:ChallengeType_COLLECT_BONES ct:18 reward:1], //todo
        [ChallengeInfo cons_name:@"tutorial_spikes" type:ChallengeType_FIND_SECRET ct:1 reward:1],
        [ChallengeInfo cons_name:@"tutorial_spikevine" type:ChallengeType_TIMED ct:1 reward:1], //0:20
        [ChallengeInfo cons_name:@"tutorial_swipeget" type:ChallengeType_COLLECT_BONES ct:1 reward:1],  //todo
        [ChallengeInfo cons_name:@"easy_world1" type:ChallengeType_FIND_SECRET ct:1 reward:1],
        [ChallengeInfo cons_name:@"tutorial_swingvine" type:ChallengeType_COLLECT_BONES ct:1 reward:1],  //todo
        [ChallengeInfo cons_name:@"classic_trickytreas" type:ChallengeType_COLLECT_BONES ct:28 reward:1],
        [ChallengeInfo cons_name:@"easy_gottagofast" type:ChallengeType_COLLECT_BONES ct:60 reward:1],
        [ChallengeInfo cons_name:@"filler_directdrop" type:ChallengeType_FIND_SECRET ct:1 reward:1],
        [ChallengeInfo cons_name:@"filler_smgislands" type:ChallengeType_COLLECT_BONES ct:52 reward:1],
        [ChallengeInfo cons_name:@"swingvine_bounswindodg" type:ChallengeType_TIMED ct:1 reward:1] //0:20
    ];
}

+(int)get_number_for_challenge:(ChallengeInfo *)c {
    return [_CHALLENGES indexOfObject:c];
}

+(int)get_num_challenges {
    return [_CHALLENGES count];
}

+(ChallengeInfo*)get_challenge_number:(int)i {
    if (i >= [self get_num_challenges]) [NSException raise:@"Challenge Not Found:" format:@"%d",i];
    return _CHALLENGES[i];
}

+(BOOL)get_beaten_challenge:(int)i {
    return [DataStore get_int_for_key:[self challenge_to_key:i]];
}

+(void)set_beaten_challenge:(int)i to:(BOOL)k {
    [DataStore set_key:[self challenge_to_key:i] int_value:k];
}

+(NSString*)challenge_to_key:(int)i {
    return [NSString stringWithFormat:@"challenge_%d",i];
}

+(int)get_highest_available_challenge {
    int max = 0;
    for (int i = 0; i<[self get_num_challenges]; i++) {
        if ([self get_beaten_challenge:i]) {
            max = i+1;
        }
    }
    if (max > [self get_num_challenges]) {
        max = [self get_num_challenges];
    }
    return max;
}

@end
