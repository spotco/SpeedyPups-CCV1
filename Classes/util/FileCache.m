#import "FileCache.h"
#import "Resource.h"

#define PLIST @"plist"

@implementation FileCache

static NSMutableDictionary* files;

+(void)precache_files {
	[self cache_file:TEX_INTRO_ANIM_SS];
	[self cache_file:TEX_GROUND_DETAILS];
	[self cache_file:TEX_DOG_RUN_1];
	[self cache_file:TEX_DOG_RUN_2];
	[self cache_file:TEX_DOG_RUN_3];
	[self cache_file:TEX_DOG_RUN_4];
	[self cache_file:TEX_DOG_RUN_5];
	[self cache_file:TEX_DOG_RUN_6];
	[self cache_file:TEX_DOG_RUN_7];
	[self cache_file:TEX_DOG_SPLASH];
	[self cache_file:TEX_DOG_ARMORED];
	[self cache_file:TEX_SWEATANIM_SS];
	[self cache_file:TEX_DASHJUMPPARTICLES_SS];
	[self cache_file:TEX_GOAL_SS];
	[self cache_file:TEX_BG2_CLOUDS_SS];
	[self cache_file:TEX_BG3_GROUND_DETAIL_SS];
	[self cache_file:TEX_FISH_SS];
	[self cache_file:TEX_BIRD_SS];
	[self cache_file:TEX_JUMPPAD];
	[self cache_file:TEX_SPEEDUP];
	[self cache_file:TEX_CANNON_SS];
	[self cache_file:TEX_ITEM_SS];
	[self cache_file:TEX_PARTICLES];
	[self cache_file:TEX_ENEMY_ROBOT];
	[self cache_file:TEX_ENEMY_LAUNCHER];
	[self cache_file:TEX_ENEMY_COPTER];
	[self cache_file:TEX_EXPLOSION];
	[self cache_file:TEX_ENEMY_SUBBOSS];
	[self cache_file:TEX_ENEMY_ROBOTBOSS];
	[self cache_file:TEX_CANNONFIRE_PARTICLE];
	[self cache_file:TEX_CANNONTRAIL];
	[self cache_file:TEX_UI_INGAMEUI_SS];
	[self cache_file:TEX_TUTORIAL_OBJ];
	[self cache_file:TEX_TUTORIAL_ANIM_1];
	[self cache_file:TEX_TUTORIAL_ANIM_2];
	[self cache_file:TEX_NMENU_ITEMS];
	[self cache_file:TEX_NMENU_LEVELSELOBJ];
	[self cache_file:TEX_FREERUNSTARTICONS];
}

+(void)cache_file:(NSString*)file {
	[files setValue:[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:PLIST]] forKey:file];
	if ([files objectForKey:file] == NULL) NSLog(@"FileCache::FILE NOT FOUND:%@",file);
	
	/*
	NSDictionary *dict = [files objectForKey:file];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dict forKey:@"dictKey"];
	[archiver finishEncoding];
	
	NSInteger bytes=[data length];
	float kbytes=bytes/1024.0;
	NSLog(@"file (%@) size:%f",file,kbytes);
	 */
}

+(CGRect)get_cgrect_from_plist:(NSString*)file idname:(NSString*)idname {
    if (files == NULL) {
        files = [[NSMutableDictionary alloc] init];
    }
    if (![files objectForKey:file]) {
		[self cache_file:file];
		NSLog(@"DELAYED CACHEING OF %@",file);
    }
    NSDictionary *tar = [files objectForKey:file];
    CGRect rtv = [Common ssrect_from_dict:tar tar:idname];
	//if (rtv.size.height == 0 && rtv.size.width == 0) NSLog(@"Empty cgrect for file(%@) tar(%@)",file,idname);
	return rtv;
}

@end
