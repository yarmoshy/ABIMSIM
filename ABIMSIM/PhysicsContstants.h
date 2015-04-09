//
//  PhysicsContstants.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/31/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#ifndef ABIMSIM_PhysicsContstants_h
#define ABIMSIM_PhysicsContstants_h

#import <Foundation/Foundation.h>

static NSString* removedThisSprite = @"removedThisSprite";

static NSString* shipCategoryName = @"ship";
static NSString* asteroidCategoryName = @"asteroid";
static NSString* asteroidInShieldCategoryName = @"asteroidInShield";
static NSString* planetCategoryName = @"planet";
static NSString* blackHoleCategoryName = @"blackHole";

static NSString* asteroidShieldCategoryName = @"asteroidShield";
static NSString* goalCategoryName = @"goal";
static NSString* levelNodeName = @"level";
static NSString* powerUpShieldName = @"shield";
static NSString* powerUpShieldRingName = @"shieldGlow";
static NSString* powerUpSpaceMineName = @"spaceMine";
static NSString* powerUpSpaceMineGlowName = @"spaceMineGlow";
static NSString* powerUpSpaceMineExplodeRingName = @"powerUpSpaceMineExplodeRingName";
static NSString* powerUpSpaceMineExplodeGlowName = @"powerUpSpaceMineExplodeGlowName";
static NSString* explodingSpaceMine = @"explodingSpaceMine";
static NSString* explodedSpaceMine = @"explodedSpaceMine";

static NSString* shipImageSpriteName = @"shipImageSprite";
static NSString* shipThrusterSpriteName = @"shipThrusterSpriteName";
static NSString* shipShieldSpriteName = @"shipShieldSprite";
static NSString* sunObjectSpriteName = @"sunObjectSpriteName";
static NSString* directionsSpriteName = @"directionsSpriteName";
static NSString* directionsSecondarySpriteName = @"directionsSecondarySpriteName";
static NSString* directionsSecondaryBlinkingSpriteName = @"directionsSecondaryBlinkingSpriteName";

static NSString* pauseSpriteName = @"pauseSpriteName";
static NSString* upgradeSpriteName = @"upgradeSpriteName";
static NSString* gameCenterSpriteName = @"gameCenterSpriteName";
static NSString* twitterSpriteName = @"twitterSpriteName";
static NSString* facebokSpriteName = @"facebokSpriteName";
static NSString* asteroidShieldRing1SpriteName = @"asteroidShieldRing1SpriteName";
static NSString* starSpriteName = @"starSpriteName";

static const uint32_t borderCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t shipCategory  = 0x1 << 1;  // 00000000000000000000000000000001
static const uint32_t secondaryBorderCategory  = 0x1 << 2;  // 00000000000000000000000000000100
static const uint32_t asteroidCategory = 0x1 << 3;
static const uint32_t asteroidInShieldCategory = 0x1 << 4;
static const uint32_t planetCategory = 0x1 << 5;
static const uint32_t asteroidShieldCategory = 0x1 << 6;
static const uint32_t starCategory = 0x1 << 7;
static const uint32_t blackHoleCategory = 0x1 << 8;
static const uint32_t goalCategory = 0x1 << 9;
static const uint32_t powerUpShieldCategory = 0x1 << 10;
static const uint32_t powerUpSpaceMineCategory = 0x1 << 11;
static const uint32_t powerUpSpaceMineExplodingRingCategory = 0x1 << 12;

#endif

