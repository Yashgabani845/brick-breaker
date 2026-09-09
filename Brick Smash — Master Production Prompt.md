# BRICK SMASH
## Master Game Development Prompt
### Production Specification for a Mobile Paddle-Controlled Brick Breaker

---

# 0. CRITICAL INSTRUCTION

Build a mobile game called **Brick Smash**.

This document defines the **new official gameplay direction**.

## DO NOT BUILD THE PREVIOUS VERSION

Do **not** build the earlier mega-density / many-ball / aim-and-fire version.

Do not implement:

- 300–500 simultaneous balls
- 500+ active physics objects
- a launch-angle-only gameplay loop
- a bottom danger-line progression system
- giant 20–30 column brick fields
- 120 FPS swarm simulation
- large-scale spatial-hash optimization designed around hundreds of balls
- the previous funnel-infiltration gameplay
- the previous continuous ball-ammo loop

Those concepts are explicitly out of scope for V1.

---

# 1. CORE GAME IDENTITY

## Game Name

**Brick Smash**

## Genre

Casual arcade brick breaker.

## Platform

Android first.

Architecture should remain portable to iOS later.

## Orientation

Portrait.

## Core Interaction

The player controls a **horizontal paddle** near the bottom of the screen.

The ball automatically moves and bounces around the play field.

The player moves the paddle left and right using touch.

The objective is to destroy all required bricks and complete the level.

---

# 2. ONE-SENTENCE GAME DESCRIPTION

**Brick Smash is a satisfying, fast-paced brick breaker where players control a paddle, bounce balls into colorful numbered bricks, collect powerful upgrades, and clear increasingly challenging levels.**

---

# 3. CORE GAME LOOP

The complete loop must be:

```text
OPEN LEVEL
    ↓
SEE BRICK FORMATION
    ↓
BALL LAUNCHES
    ↓
MOVE PADDLE
    ↓
KEEP BALL ALIVE
    ↓
BREAK BRICKS
    ↓
COLLECT POWER-UPS
    ↓
TRIGGER COMBOS / SPECIAL EFFECTS
    ↓
BREAK MORE BRICKS
    ↓
CLEAR ALL REQUIRED BRICKS
    ↓
LEVEL COMPLETE
    ↓
REWARD SCREEN
    ↓
NEXT LEVEL
```

The player should immediately understand the game without a tutorial after the first few seconds.

---

# 4. DESIGN PHILOSOPHY

The game should feel:

- easy to understand
- satisfying
- responsive
- colorful
- polished
- lightweight
- quick to replay
- increasingly challenging
- visually rewarding

The game should **not** feel like an old Flash-era Breakout clone.

The mechanics can be familiar, but presentation and progression should feel modern.

---

# 5. WHAT MAKES BRICK SMASH DIFFERENT

Brick Smash should differentiate itself using:

## 5.1 Strong visual feedback

Every brick hit should produce:

- a tiny impact flash
- particle fragments
- subtle screen feedback
- satisfying hit sound
- visible damage progression

Destroyed bricks should feel rewarding.

## 5.2 Modern brick design

Bricks should look like polished arcade blocks with:

- rounded corners
- bevels
- subtle depth
- inner highlights
- damage states
- color-coded strength

## 5.3 Power-up moments

The most exciting moments should come from combinations such as:

```text
Wide Paddle
+
Multiball
+
Fire Ball
=
Massive Clear
```

## 5.4 Level variety

Do not simply increase numbers forever.

New formations, obstacles and mechanics should gradually appear.

---

# 6. CORE GAMEPLAY

## 6.1 Player Paddle

The paddle sits near the bottom of the playable area.

The player moves it horizontally.

Default behavior:

- follows finger position
- smooth movement
- constrained within left and right boundaries
- no vertical movement
- no inertia that makes control feel delayed

The paddle should feel immediately responsive.

### Input

Primary input:

**Horizontal finger drag**

Touch anywhere in the lower gameplay region should allow paddle movement.

Optional alternative:

Direct touch-to-position.

Do not require the player to precisely drag the paddle itself.

---

# 7. BALL SYSTEM

## 7.1 Default Ball

There is one standard ball at the beginning of a level.

The ball should have:

- bright core
- glow
- subtle trail
- visible highlight
- consistent collision radius

## 7.2 Ball Movement

The ball moves continuously.

It can collide with:

- walls
- paddle
- bricks
- special obstacles

## 7.3 Ball Speed

Ball speed should remain controlled.

Avoid extremely slow gameplay.

Avoid uncontrollably fast gameplay.

The game should accelerate naturally as levels become harder.

Use difficulty presets rather than randomly changing speed.

---

# 8. PADDLE PHYSICS

The paddle should influence the ball's outgoing angle.

Do not make every paddle collision a simple horizontal mirror.

Use hit position.

Conceptually:

```text
Left edge of paddle
        ↓
ball exits left

Center of paddle
        ↓
ball exits upward

Right edge of paddle
        ↓
ball exits right
```

The further from center the impact occurs, the more horizontal influence is applied.

Clamp the outgoing angle so the ball does not become nearly horizontal.

### Required safeguard

Never allow the ball to enter a trajectory where it can bounce almost endlessly horizontally.

Maintain a minimum useful vertical component.

---

# 9. BALL LOSS

If the ball falls below the paddle:

- ball is lost
- life count decreases
- if remaining lives > 0, allow recovery
- if no lives remain, level fails

Default V1:

**3 lives per level**

This can later be tuned using analytics.

---

# 10. MULTIBALL

Multiball is one of the primary excitement mechanics.

Power-up examples:

- +1 ball
- +2 balls
- +3 balls

When activated, additional balls should inherit reasonable trajectories.

Do not spawn hundreds of balls.

Target normal V1 maximum:

**3–5 simultaneous balls**

A rare late-game power-up may allow more, but performance should always remain lightweight.

---

# 11. BRICK SYSTEM

Bricks are the main gameplay objects.

Every brick must have:

- position
- size
- type
- hit points
- max hit points
- destroyed state
- visual state
- optional special effect

---

# 12. STANDARD BRICKS

Standard bricks represent the majority of levels.

Example HP progression:

```text
1
2
3
5
10
15
25
50
75
100
```

Do not jump too aggressively.

Early levels should remain readable and satisfying.

---

# 13. BRICK VISUAL HEALTH STATES

A brick with high HP should visually communicate strength.

Possible states:

### Full health

Clean glossy appearance.

### Damaged

Visible cracks.

### Heavy damage

More cracks / reduced glow.

### Final hit

Strong impact animation.

### Destroyed

Break into fragments and disappear.

The number should remain readable.

---

# 14. BRICK COLORS

Use color families to communicate HP tiers.

Example:

```text
Low HP      → Blue
Medium HP   → Green
Higher HP   → Orange
High HP     → Red
Very high   → Purple
Special     → Unique treatment
```

The exact palette can be adjusted during visual production.

Do not rely on color alone for critical information.

Numbers must remain visible.

---

# 15. SPECIAL BRICKS

The game should have several special brick types.

## 15.1 Bomb Brick

When destroyed:

- creates radial explosion
- damages nearby bricks
- creates particles
- plays explosive audio
- awards bonus score

Example:

```text
        X
      X X X
    X X 💣 X X
      X X X
        X
```

Explosion radius should be clearly readable.

---

# 16. LASER BRICK

When destroyed:

- fires a horizontal laser
- damages bricks along the row
- triggers visual beam
- produces chain effects if appropriate

The beam should be fast and readable.

---

# 17. VERTICAL LASER BRICK

When activated:

- shoots vertically
- damages bricks in its column

Use sparingly during early progression.

---

# 18. CROSS BRICK

An advanced special brick.

When destroyed:

- fires horizontal beam
- fires vertical beam
- creates larger spectacle

It should be rare enough that players get excited when they see one.

---

# 19. UNBREAKABLE BRICK

A steel-style obstacle.

It cannot be destroyed normally.

Purpose:

- changes ball trajectory
- creates level geometry
- creates strategic angles
- prevents repetitive formations

Use sparingly.

---

# 20. BONUS BRICKS

Some bricks can contain rewards.

Example:

```text
★ Bonus
+
Coin
+
Power-up
```

Breaking one gives additional rewards.

---

# 21. POWER-UP SYSTEM

Power-ups should be one of the primary progression mechanics.

Initial V1 power-ups:

### 1. Multiball

Adds balls.

### 2. Fireball

Ball passes through multiple bricks without normal bounce behavior for a limited duration.

### 3. Wide Paddle

Temporarily enlarges paddle.

### 4. Slow Ball

Temporarily reduces ball speed.

### 5. Laser Paddle

Paddle gains the ability to fire controlled laser shots.

### 6. Magnet Paddle

Temporarily catches the ball and gives the player manual release/control.

Do not launch with all six unless the implementation remains stable.

The first release can start with:

- Multiball
- Fireball
- Wide Paddle
- Slow Ball

and expand later.

---

# 22. POWER-UP COLLECTION

Power-ups should appear visually from destroyed bricks.

They should fall downward.

The player catches them with the paddle.

Example:

```text
        💥
        ↓
       ⚡
        ↓
      ━━━━━
      PADDLE
```

If a power-up reaches the bottom without touching the paddle, it disappears.

Catching it activates the effect.

---

# 23. POWER-UP COLORS

Each power-up should have a unique visual identity.

Examples:

Multiball:
- glowing multi-orb icon

Fireball:
- flame icon

Wide Paddle:
- wide paddle icon

Slow:
- clock / snow / slowdown icon

Do not use ambiguous icons.

---

# 24. COMBO SYSTEM

Reward players for destroying bricks rapidly.

Example:

```text
1 HIT
2 HIT
3 HIT
4 HIT
5 HIT
COMBO x5
```

Combo should increase score multiplier.

The combo should reset after sufficient inactivity.

Use a forgiving timing window.

The purpose is to make the player feel clever and powerful.

---

# 25. SCORE SYSTEM

Score should be easy to understand.

Base score:

```text
brick HP × multiplier
```

Special bricks award additional score.

Combos multiply score.

Example:

```text
Brick destroyed   +100
Combo x3           +300
Bomb chain         +500
Power-up brick     +250
```

Exact values should be configurable.

---

# 26. LEVEL OBJECTIVE

Primary objective:

**Destroy all required destructible bricks.**

Some levels can include a secondary objective.

Examples:

- Clear all bricks
- Reach target score
- Break X special bricks
- Finish using fewer than X lives
- Trigger a combo
- Collect specific power-ups

However, the first levels should use the simplest objective:

**Clear all bricks.**

---

# 27. LEVEL COMPLETION

A level is completed when all required destructible bricks are destroyed.

Do not immediately transition away.

Pause gameplay for a short victory moment.

Show:

- final score
- stars
- coins
- best score
- combo achievement
- buttons for next level / retry / home

---

# 28. STAR RATING

Use a three-star rating.

Example:

### 1 Star
Complete the level.

### 2 Stars
Complete with good performance.

### 3 Stars
Complete with excellent performance.

Possible factors:

- lives remaining
- score
- time
- combo
- bricks broken
- power-ups used

Do not make requirements frustrating.

---

# 29. LEVEL FAILURE

Show failure when:

- all lives are lost

The player receives:

- final score
- best score
- retry button
- optional rewarded recovery
- home button

Avoid punishment-heavy UX.

---

# 30. REWARDED CONTINUE

Optional rewarded video:

**“Save Me”**

Restore one lost life or revive the current level state.

This should occur only at a meaningful failure point.

Do not spam rewarded ads.

---

# 31. LEVEL STRUCTURE

V1 should launch with approximately:

**50–100 levels**

Prefer quality over quantity.

The first 20 levels should be particularly polished.

---

# 32. LEVEL DIFFICULTY CURVE

Example:

## Levels 1–5
Tutorial-like.

- basic bricks
- slow ball
- simple formations

## Levels 6–10

- slightly stronger bricks
- wider layouts
- first power-ups

## Levels 11–20

- mixed HP
- more challenging formations
- bombs

## Levels 21–30

- steel blocks
- tighter corridors
- higher HP

## Levels 31–40

- lasers
- advanced formations

## Levels 41–50

- combinations
- more difficult bounce paths
- multi-stage challenge layouts

The exact curve should remain configurable.

---

# 33. LEVEL DESIGN PRINCIPLE

Never make difficulty come only from:

> “Give every brick a bigger number.”

Difficulty should also come from:

- geometry
- brick placement
- obstacles
- angles
- power-up positioning
- risk/reward choices
- limited paddle area
- mixed HP values

---

# 34. LEVEL FORMATION TYPES

Create reusable formation templates.

Examples:

### Wall

```text
████████████
████████████
████████████
```

### Pyramid

```text
     ██
    ████
   ██████
  ████████
```

### Diamond

```text
    ██
  ██████
██████████
  ██████
    ██
```

### Tunnel

```text
███      ███
███      ███
███      ███
████████████
```

### Fortress

```text
████████████
██        ██
██  ████  ██
██        ██
████████████
```

### Zigzag

Alternating brick walls that create challenging bounce angles.

---

# 35. SPECIAL LEVEL DESIGN

Every group of levels should introduce something.

Do not dump every mechanic into Level 2.

Example:

```text
1–5     Basic
6–10    Power-ups
11–15   Bombs
16–20   Obstacles
21–25   Steel
26–30   Lasers
31–40   Mixed mechanics
41–50   Advanced combinations
```

---

# 36. BOSS / CHALLENGE LEVELS

Optional V1 feature.

Every 10 levels can contain a special challenge.

Instead of a conventional boss character, use a giant formation.

Example:

**MEGA BLOCK**

A large central structure must be destroyed while surrounding bricks create pressure.

This keeps the game consistent with its identity.

---

# 37. GAMEPLAY CAMERA

Gameplay should be a flat 2D play field presented with a polished 2.5D visual style.

Do not turn the game into a true 3D physics game.

The visual language can use:

- perspective
- bevels
- shadows
- glow
- depth
- particle effects

But collision and gameplay should remain simple and predictable.

---

# 38. SCREEN LAYOUT

Recommended portrait layout:

```text
┌───────────────────────────┐
│ ⚙        LEVEL 28      ★★☆ │
│      SCORE 12,680          │
├───────────────────────────┤
│                           │
│      BRICK FIELD          │
│                           │
│   ███ ███ ███ ███ ███    │
│   ███ ███ 💣 ███ ███     │
│     ███     ███           │
│                           │
│             ⚪            │
│          ↙                │
│                           │
│                           │
│                           │
│      ━━━━━━━━━━━          │
│         PADDLE            │
├───────────────────────────┤
│   ⚡      🔥      ✨       │
└───────────────────────────┘
```

The actual gameplay region should receive the largest amount of screen space.

---

# 39. GAMEPLAY HUD

Top HUD:

### Left

Pause button.

### Center

Level number.

### Below or nearby

Star progress.

### Right

Current score.

Optional:

Best score.

Keep the HUD minimal.

Gameplay should remain the visual priority.

---

# 40. PADDLE DESIGN

The paddle should be one of the major recognizable visual assets.

Design direction:

- futuristic arcade
- rounded geometry
- glowing edge
- glossy center
- subtle particle trail
- premium appearance

Default paddle can be:

**electric blue / cyan**

Future paddle skins can change:

- color
- shape
- particle trail
- glow
- material

Skins should not alter gameplay unfairly.

---

# 41. BALL DESIGN

Default ball:

- bright white/cyan core
- blue halo
- subtle trail

Alternative ball skins:

- Fire
- Plasma
- Ice
- Galaxy
- Rainbow
- Gold

Again:

**cosmetic only.**

---

# 42. BRICK STYLE

Bricks should feel like polished arcade blocks.

Visual treatment:

- rounded rectangle
- slight bevel
- soft shadow
- bright front face
- deeper side shading
- number centered
- impact cracks
- destruction fragments

Avoid making bricks look flat and lifeless.

---

# 43. TRAJECTORY / AIMING

The game does **not** require a trajectory aiming phase like the earlier version.

The player influences the ball primarily through the paddle.

Optional future mechanic:

A pre-shot guide may appear only for a special ability.

Do not make aiming the primary gameplay loop.

---

# 44. GAME FEEL

This is one of the highest-priority systems.

Every interaction should have immediate feedback.

### Brick hit

- tiny scale pulse
- flash
- particle burst
- sound

### Brick destroy

- stronger particles
- fragments
- impact sound
- score popup

### Bomb

- expanding shockwave
- stronger sound
- nearby brick reactions

### Paddle hit

- tiny glow pulse
- bounce sound

### Multiball

- dramatic activation
- multiple launch effects

---

# 45. ANIMATION RULES

Animations should be:

- quick
- readable
- responsive

Avoid slow transitions during gameplay.

Target:

**50–250 ms** for most micro-interactions.

Major events may be longer.

---

# 46. PARTICLES

Particles should include:

- brick shards
- glow sparks
- small dust bursts
- power-up particles
- laser particles
- bomb particles
- ball trails

Particle count must remain reasonable.

Avoid particle systems that can degrade low-end Android devices.

---

# 47. SCREEN SHAKE

Use extremely subtle screen shake.

Only for:

- bomb explosions
- major combo events
- special clears

Never shake the screen constantly.

Provide reduced-motion behavior.

---

# 48. SOUND DESIGN

The game should have a satisfying arcade soundscape.

Required categories:

- paddle hit
- brick hit
- brick destroyed
- combo
- power-up
- bomb
- laser
- level complete
- level fail
- button tap
- reward

Repeated sounds should not become irritating.

Pitch variation can prevent repetition.

---

# 49. MUSIC

Use lightweight looping background music.

Early direction:

- energetic
- playful
- futuristic
- casual

Music should not overwhelm impact sounds.

Allow:

- Music ON/OFF
- SFX ON/OFF

---

# 50. HOME SCREEN

The Home screen should communicate the game instantly.

Recommended structure:

```text
┌──────────────────────────┐
│ Coins      Gems      ⚙   │
│                          │
│      BRICK SMASH         │
│                          │
│       [ GAME ART ]       │
│                          │
│       ▶ PLAY             │
│       Level 28           │
│                          │
│   Daily      Level Map   │
│ Challenge                │
│                          │
│ Shop   Balls   Skins     │
│                          │
│       Leaderboard        │
└──────────────────────────┘
```

The **Play** button should dominate.

Do not bury the primary action in a grid of tiny buttons.

---

# 51. HOME SCREEN HERO ART

Use the Brick Smash logo near the top.

Behind it:

- glowing ball
- broken bricks
- particles
- futuristic environment
- strong blue/purple atmosphere

Keep the central interaction area clear.

---

# 52. PLAY BUTTON

Primary button:

**PLAY**

Secondary text:

**LEVEL 28**

Button should have:

- large touch target
- subtle animation
- strong contrast
- obvious hierarchy

Do not make the Home screen overly complicated.

---

# 53. LEVEL MAP

The game should have a simple progression map.

Players travel through level nodes.

Example:

```text
1
  \
   2
    \
     3
      \
       4
        \
         5
```

Every section can have a visual theme.

Example themes:

- Neon Valley
- Crystal Zone
- Lava Core
- Cyber City
- Cosmic Arena

---

# 54. LEVEL MAP NODE

Each node shows:

- level number
- stars
- unlocked/locked state

Current level should be visually emphasized.

Completed levels can display:

```text
★★★
```

---

# 55. DAILY CHALLENGE

Include a Daily Challenge.

Daily challenge can modify:

- brick formation
- power-up availability
- ball speed
- special objective

Example:

**“Clear this board with only 1 life.”**

Rewards:

- coins
- gems
- cosmetics

---

# 56. SHOP

Shop categories:

### Balls
Cosmetic balls.

### Paddles
Cosmetic paddles.

### Themes
Background themes.

### Bundles
Cosmetic bundles.

Avoid selling unavoidable gameplay advantages in V1.

---

# 57. SKINS

Cosmetics should be visibly attractive.

Example ball skins:

- Fireball
- Ice Orb
- Plasma Orb
- Galaxy Orb
- Gold Orb

Example paddle skins:

- Neon Blade
- Cyber Bar
- Crystal Paddle
- Lava Paddle
- Space Paddle

Skins can include different trails and destruction effects.

---

# 58. CURRENCY

Primary currency:

**Coins**

Secondary premium currency:

**Gems**

Use coins for common cosmetic unlocks.

Use gems for premium cosmetics.

Do not build a complicated economy initially.

---

# 59. REWARDS

Players should receive rewards from:

- level completion
- stars
- daily challenge
- daily login
- achievements
- missions

---

# 60. DAILY LOGIN

Simple seven-day reward cycle.

Example:

```text
Day 1 → Coins
Day 2 → Coins
Day 3 → Power-up
Day 4 → Gems
Day 5 → Coins
Day 6 → Cosmetic
Day 7 → Premium reward
```

Rewards should feel progressively better.

---

# 61. ACHIEVEMENTS

Examples:

### First Smash
Complete first level.

### Brick Storm
Destroy 100 bricks.

### Combo Master
Reach x10 combo.

### Multiball Madness
Have 5 balls active.

### Bomb Expert
Trigger 50 bomb destructions.

### Perfect Run
Complete a level without losing a life.

---

# 62. MISSIONS

Simple mission examples:

- destroy 100 bricks
- use 3 power-ups
- complete 5 levels
- achieve x5 combo
- destroy 10 bombs

Missions create a secondary reason to keep playing.

---

# 63. RETENTION LOOP

The target loop is:

```text
PLAY
 ↓
COMPLETE LEVEL
 ↓
EARN REWARD
 ↓
UNLOCK / UPGRADE COSMETIC
 ↓
SEE NEXT LEVEL
 ↓
PLAY AGAIN
```

Daily challenge and missions add secondary return loops.

---

# 64. ADS

Do not destroy the game with ads.

## Do not use:

- constant mid-game interruptions
- ads immediately after every level
- forced ads during active gameplay

## Preferred:

Rewarded ads.

Examples:

**Double Coins**

**Save One Life**

**Double Level Reward**

**Continue**

Optional interstitial ads can be used conservatively between suitable gameplay sessions.

---

# 65. PREMIUM REMOVE ADS

Offer an optional purchase:

**Remove Ads**

The exact price should be configurable by region.

Do not hard-code pricing into gameplay logic.

---

# 66. STORE MONETIZATION PRINCIPLE

Players should never feel that the game is deliberately made frustrating so they will pay.

Monetization should enhance convenience and cosmetics.

---

# 67. SETTINGS

Settings screen should contain:

- Sound
- Music
- Vibration
- Notifications
- Language
- Restore Purchases
- Privacy
- Terms
- Support
- Reset Progress confirmation

---

# 68. PAUSE MENU

Pause screen:

```text
PAUSED

Resume
Restart
Settings
Home
```

Do not clutter it.

---

# 69. LEVEL COMPLETE SCREEN

Recommended:

```text
LEVEL COMPLETE!

★★★
Score: 28,450

Coins +250
Bonus +100

BEST SCORE!

[ 2X COINS ]
[ NEXT LEVEL ]
```

The main action should be:

**NEXT LEVEL**

---

# 70. LEVEL FAIL SCREEN

Recommended:

```text
LEVEL FAILED

Score: 8,420

[ SAVE ME ]
Watch Video

[ RETRY ]

[ HOME ]
```

The primary button should be Retry.

---

# 71. ONBOARDING

Keep onboarding minimal.

Maximum three pages.

### Screen 1

**Break the Bricks**

Visual:
paddle + ball + brick field.

### Screen 2

**Control the Paddle**

Visual:
finger moving paddle.

### Screen 3

**Use Power-Ups**

Visual:
multiball / bomb / fireball.

Then:

**PLAY**

Do not use a long tutorial carousel.

---

# 72. FIRST-TIME TUTORIAL

After onboarding, launch a very simple first level.

Show a short visual hint:

**MOVE TO CATCH THE BALL**

Then remove the hint quickly.

The player should learn through interaction.

---

# 73. FIRST FIVE MINUTES

The first five minutes are critical.

Players should experience:

1. immediate gameplay
2. first destruction
3. first power-up
4. first level complete
5. first reward
6. second level
7. first challenge

Avoid menus before gameplay.

---

# 74. DIFFICULTY PHILOSOPHY

Difficulty should rise gradually.

Do not make Level 5 feel like Level 50.

Introduce one new idea at a time.

---

# 75. FAIRNESS

Every failure should feel understandable.

Avoid:

- invisible collision
- random impossible trajectories
- unfair power-up placement
- impossible angles
- sudden unexplained speed boosts

The player should think:

> “I can do that better.”

rather than:

> “The game cheated.”

---

# 76. COLLISION SYSTEM

Use deterministic 2D collision.

Objects:

- Ball
- Paddle
- Brick
- PowerUp
- Wall
- Special obstacle

Collision handling must avoid:

- tunneling
- duplicate hits
- repeated collision events
- ball getting trapped inside bricks
- infinite zero-velocity states

---

# 77. PHYSICS SAFETY

Maintain:

- minimum ball speed
- valid direction
- bounded velocity
- collision cooldown where needed
- separation after impact

After paddle collision:

1. determine impact point
2. calculate bounce angle
3. normalize velocity
4. enforce minimum vertical component
5. continue simulation

---

# 78. BALL-BRICK COLLISION

When the ball contacts a brick:

1. calculate collision
2. determine correct bounce
3. reduce HP
4. trigger hit effect
5. award score
6. check destruction
7. trigger special behavior if applicable

Do not allow one collision to damage the same brick repeatedly during the same frame.

---

# 79. POWER-UP COLLISION

Power-up collision with paddle:

1. detect overlap
2. collect
3. remove falling item
4. activate effect
5. play audio
6. create visual effect

---

# 80. GAME STATE

Use clean game states:

```text
Loading
Home
LevelSelect
Playing
Paused
LevelComplete
LevelFailed
Reward
Shop
Settings
```

Gameplay logic must not be mixed directly into UI widgets.

---

# 81. ARCHITECTURE

Use a modular architecture.

Suggested structure:

```text
lib/
 ├── core/
 │    ├── constants/
 │    ├── theme/
 │    ├── audio/
 │    ├── storage/
 │    └── utilities/
 │
 ├── game/
 │    ├── models/
 │    ├── physics/
 │    ├── renderer/
 │    ├── levels/
 │    ├── powerups/
 │    ├── effects/
 │    └── game_controller/
 │
 ├── features/
 │    ├── home/
 │    ├── gameplay/
 │    ├── levels/
 │    ├── shop/
 │    ├── daily_challenge/
 │    ├── achievements/
 │    └── settings/
 │
 └── main.dart
```

Keep gameplay and presentation separate.

---

# 82. FLUTTER IMPLEMENTATION

The game can use Flutter with a lightweight custom rendering approach.

Use:

- CustomPainter where appropriate
- efficient animation controllers
- low-allocation update loops
- immutable configuration where practical
- lightweight state management

Do not create hundreds of unnecessary Flutter widgets for gameplay objects.

---

# 83. PERFORMANCE TARGET

Primary target:

**stable 60 FPS on mainstream Android devices.**

Do not optimize for 120 FPS as a core requirement.

The game should perform smoothly on mid-range devices.

---

# 84. MEMORY

Avoid:

- unnecessary image duplication
- oversized textures
- excessive particle assets
- leaked animation controllers
- unbounded lists
- unnecessary object allocation during the frame loop

---

# 85. RENDERING

Use cached rendering resources where possible.

Do not rebuild static assets unnecessarily.

The brick field should be rendered efficiently.

---

# 86. RESPONSIVE DESIGN

Support common Android portrait sizes.

The game should scale based on available screen dimensions.

Do not hard-code coordinates for one specific phone.

Create a gameplay coordinate system independent of device pixels.

---

# 87. SAFE AREAS

Respect:

- status bar
- navigation areas
- display cutouts
- rounded corners

Keep important controls inside usable bounds.

---

# 88. ACCESSIBILITY

Support:

- readable text
- high contrast
- vibration toggle
- reduced motion where practical
- color-independent information

Numbers on bricks should remain readable.

---

# 89. DATA STORAGE

Persist:

- current level
- completed levels
- stars
- best scores
- currencies
- owned cosmetics
- selected cosmetic
- settings
- tutorial completion
- daily challenge state
- achievements

---

# 90. SAVE SAFETY

Progress should not disappear when:

- app closes
- process is killed
- device restarts

Write critical state safely.

---

# 91. LEVEL DATA FORMAT

Levels should be data-driven.

Do not hard-code every level into gameplay code.

Example conceptual structure:

```json
{
  "level": 28,
  "rows": 8,
  "columns": 9,
  "ballSpeed": 420,
  "lives": 3,
  "bricks": [
    {
      "row": 0,
      "column": 0,
      "type": "standard",
      "hp": 20
    }
  ]
}
```

Actual implementation can use Dart models or JSON.

---

# 92. LEVEL EDITOR FRIENDLINESS

The level system should make it easy to create new levels without rewriting gameplay code.

A designer should be able to change:

- brick positions
- HP
- special brick types
- obstacles
- power-up probabilities
- background
- ball speed

---

# 93. THEMING SYSTEM

Each chapter can change background environment.

Example:

### Chapter 1
Neon Valley

### Chapter 2
Crystal Cavern

### Chapter 3
Lava Planet

### Chapter 4
Cyber City

### Chapter 5
Galaxy Core

Gameplay rules remain consistent.

---

# 94. BACKGROUND ART

Backgrounds should never compete with bricks.

Use:

- dark gradient
- atmospheric scenery
- subtle particles
- soft depth
- clean gameplay contrast

The brick field must remain the visual focus.

---

# 95. UI VISUAL LANGUAGE

Overall visual style:

**Premium casual arcade**

Use:

- rounded panels
- large buttons
- strong typography
- subtle gradients
- glossy controls
- neon accents
- controlled glow
- high contrast

Avoid:

- overly realistic graphics
- clutter
- excessive gradients
- childish cartoon characters unless introduced later

---

# 96. BRAND

Game title:

# BRICK SMASH

Logo direction:

- BRICK in orange/gold
- SMASH in icy blue
- cracked letters
- strong outline
- chunky arcade typography
- brick fragments
- energetic impact effects

The logo should be recognizable even at small sizes.

---

# 97. APP ICON

The icon should communicate:

**ball + bricks + destruction**

Recommended composition:

- glowing golden/orange ball
- colorful bricks
- impact fragments
- deep blue background
- no tiny UI elements
- no unnecessary text

The icon should read clearly at small scale.

---

# 98. HOME SCREEN BACKGROUND

Home background should be visually connected to the logo.

Recommended:

- deep blue cosmic atmosphere
- colorful floating brick chunks
- glowing ball
- distant environment
- open center area for UI

The background should be reusable as a production asset.

---

# 99. GAMEPLAY BACKGROUND

Gameplay should be darker than Home.

Reason:

Bricks, ball and effects need maximum contrast.

---

# 100. UI BUTTON HIERARCHY

Primary:

**Play**

Secondary:

- Level Map
- Daily Challenge

Tertiary:

- Shop
- Balls
- Skins
- Leaderboard
- Settings

Do not make every button equally bright.

---

# 101. INPUT FEEL

Paddle movement should have:

- no visible input lag
- no snapping
- no accidental jumps
- predictable finger mapping

Add slight smoothing only if necessary.

Prioritize responsiveness over decorative animation.

---

# 102. HAPTICS

Use light haptic feedback for:

- paddle impact
- major brick destruction
- power-up collection
- bomb
- level completion

Do not vibrate constantly.

---

# 103. GAMEPLAY SPEED

The game should be designed for short sessions.

Target:

**30 seconds to 3 minutes per level**

Later levels can become longer.

Players should be able to play:

- while commuting
- in short breaks
- repeatedly for progression

---

# 104. REPLAYABILITY

After clearing a level, players can replay for:

- 3 stars
- higher score
- achievement
- better combo
- perfect life run

This gives completed levels continued value.

---

# 105. LEADERBOARD

Optional V1 feature.

Use:

- highest score
- highest chapter score
- daily challenge score

Do not make social systems a requirement for the core game to function.

---

# 106. ANALYTICS

Track key events.

Examples:

```text
app_open
tutorial_start
tutorial_complete

level_start
level_restart
level_complete
level_fail

powerup_collected
bomb_triggered
multiball_triggered

three_star_level
daily_challenge_start
daily_challenge_complete

rewarded_ad_shown
rewarded_ad_completed
purchase_started
purchase_completed
```

---

# 107. IMPORTANT FUNNEL METRICS

Measure:

- tutorial completion
- first-level completion
- second-level completion
- level 5 completion
- level 10 completion
- retry rate
- average session length
- sessions per user
- rewarded ad opt-in
- day-1 retention
- day-7 retention
- cosmetic interaction
- daily challenge participation

---

# 108. DESIGN FOR RETENTION, NOT ARTIFICIAL FRICTION

Do not create retention by:

- excessive difficulty spikes
- forced ads
- confusing menus
- energy systems
- artificial timers

Create retention through:

- satisfying gameplay
- progression
- mastery
- cosmetics
- new mechanics
- daily challenges

---

# 109. ASO POSITIONING

The game should be positioned around searchable phrases such as:

- brick breaker
- brick breaker game
- bricks game
- ball breaker
- brick smash
- brick breaking game
- arcade brick breaker
- brick breaker offline

Keyword strategy must be validated before launch rather than blindly stuffing keywords.

---

# 110. STORE TITLE

Primary brand:

**Brick Smash**

Possible subtitle-style positioning can be tested later depending on store character limits and keyword research.

Do not force irrelevant keywords into the brand name.

---

# 111. STORE DESCRIPTION POSITIONING

The first lines should communicate:

- brick breaking
- paddle control
- power-ups
- levels
- satisfying destruction

Example positioning:

> Smash colorful bricks, control the paddle, unlock powerful upgrades, and clear hundreds of challenging levels.

Final copy should be optimized through actual ASO research.

---

# 112. SCREENSHOT STRATEGY

Store screenshots should demonstrate the game immediately.

Recommended sequence:

### Screenshot 1
**SMASH THE BRICKS**

Large gameplay action.

### Screenshot 2
**MASTER THE PADDLE**

Show paddle control.

### Screenshot 3
**POWER-UPS CHANGE EVERYTHING**

Show multiball, bomb and fireball.

### Screenshot 4
**100s OF LEVELS**

Show progression map.

### Screenshot 5
**UNLOCK EPIC COSMETICS**

Show balls and paddles.

---

# 113. APP PREVIEW / TRAILER

A short trailer should:

1. Show Brick Smash logo.
2. Show ball immediately hitting bricks.
3. Show paddle movement.
4. Show power-up.
5. Show multiball.
6. Show bomb chain.
7. Show level completion.
8. End with logo + Play-style CTA.

Do not spend the opening seconds on menus.

---

# 114. AD CREATIVE DIRECTION

The game should be easy to market through gameplay footage.

Strong ad hook:

```text
CAN YOU KEEP THE BALL ALIVE?
```

Then immediately:

- ball hits bricks
- player moves paddle
- power-up appears
- multiball activates
- huge clear

The first few seconds should contain visible action.

---

# 115. V1 SCOPE

V1 should include:

### Core

- paddle
- ball
- walls
- bricks
- HP
- lives
- level completion
- level failure

### Content

- 50+ levels
- multiple formations
- basic power-ups
- special bricks

### UI

- splash
- home
- onboarding
- level select
- gameplay
- pause
- level complete
- level failed
- settings

### Meta

- coins
- basic cosmetics
- daily challenge
- achievements
- missions

### Monetization

- rewarded ad
- conservative interstitial
- remove ads purchase

---

# 116. FEATURES TO DELAY

Do not build these before the core game is proven:

- multiplayer
- PvP
- clans
- complex social features
- battle pass
- hundreds of skins
- complicated inventory
- procedural infinite world
- live events platform
- elaborate story
- 500-ball simulations

The objective is to launch a polished game, not a huge system.

---

# 117. DEVELOPMENT PHASES

## PHASE 1 — CORE PROTOTYPE

Implement:

- paddle
- one ball
- walls
- one brick
- collision
- ball loss
- restart

Goal:

**The game must already feel fun with no UI polish.**

---

# 118. PHASE 2 — CORE GAMEPLAY

Add:

- multiple bricks
- HP
- destruction
- score
- lives
- level loading
- level completion

---

# 119. PHASE 3 — POWER-UPS

Add:

- multiball
- fireball
- wide paddle
- slow ball

Test whether each one feels immediately understandable.

---

# 120. PHASE 4 — SPECIAL BRICKS

Add:

- bombs
- lasers
- steel blocks
- bonus bricks

---

# 121. PHASE 5 — UI

Build:

- Home
- Level Map
- Gameplay HUD
- Pause
- Completion
- Failure
- Settings

---

# 122. PHASE 6 — PROGRESSION

Add:

- chapters
- stars
- rewards
- coins
- daily challenge
- missions
- achievements

---

# 123. PHASE 7 — MONETIZATION

Add:

- rewarded ads
- optional interstitial
- remove ads
- cosmetic shop

Monetization must never damage the core gameplay.

---

# 124. PHASE 8 — POLISH

Add:

- particles
- audio
- haptics
- transitions
- micro-animations
- improved backgrounds
- improved brick destruction
- improved power-up effects

---

# 125. PHASE 9 — PERFORMANCE

Test:

- low-end Android
- mid-range Android
- high-end Android

Check:

- FPS
- memory
- loading
- battery usage
- input latency

---

# 126. PHASE 10 — QA

Test every:

- brick type
- power-up
- collision
- life transition
- level completion
- level failure
- save state
- purchase state
- ad state

---

# 127. QA EDGE CASES

Specifically test:

### Ball trapped against two objects

Must eventually escape.

### Ball almost horizontal

Correct trajectory.

### Paddle at screen edge

Ball remains controllable.

### Multiball + level completion

All balls terminate correctly.

### Bomb + multiple bricks

No duplicate triggers.

### Power-up + paddle at edge

Correct collection.

### App killed during level

State recovery must be intentional and safe.

---

# 128. BUILD QUALITY BAR

A feature is not complete simply because it works technically.

Every feature must pass:

### Functionality
Does it work?

### Feel
Does it feel responsive?

### Visuals
Does it look polished?

### Audio
Does the feedback feel satisfying?

### Performance
Does it remain smooth?

### UX
Does the player understand it?

---

# 129. NO PLACEHOLDER FINAL UI

Temporary placeholders are acceptable during development.

Before release:

- no debug labels
- no placeholder rectangles
- no generic system buttons
- no developer text
- no missing icons
- no temporary art
- no debug collision lines

---

# 130. DEBUG TOOLS

Developer-only debug mode may include:

- FPS
- collision visualization
- level reload
- level selector
- unlimited lives
- power-up spawning
- ball speed
- brick HP editor

Debug features must not ship enabled for normal players.

---

# 131. CONTENT PIPELINE

Assets should be separated into:

```text
Brand Assets
UI Assets
Gameplay Assets
Brick Assets
Power-up Assets
Particle Assets
Audio Assets
Background Assets
Cosmetics
Store Assets
```

This allows rapid iteration.

---

# 132. LOGO ASSET

Use a separate transparent **Brick Smash** logo asset.

Do not bake the logo permanently into every background.

The logo should work on:

- Home
- Splash
- Store
- Ads
- Promotional graphics

---

# 133. BACKGROUND ASSET RULE

Background artwork must remain separate from UI.

UI such as:

- Play button
- currencies
- navigation
- settings

must be rendered by the application.

Do not permanently paint UI into background artwork.

---

# 134. ICON RULE

Gameplay icons should be consistent.

Use a shared icon style.

Examples:

- pause
- settings
- coins
- gems
- bomb
- multiball
- fireball
- paddle

Do not mix unrelated icon styles.

---

# 135. TYPOGRAPHY

Primary title:

Bold, chunky arcade display type.

Gameplay:

Highly readable sans-serif.

Numbers inside bricks:

Heavy weight.

Do not use decorative fonts for small gameplay values.

---

# 136. COLOR SYSTEM

Primary visual family:

- deep navy
- electric blue
- cyan
- purple
- orange
- gold

Use color strategically.

The gameplay field should have enough dark contrast that bright balls and bricks dominate.

---

# 137. VISUAL CONSISTENCY

The following must look like they belong to the same game:

- app icon
- logo
- splash
- home
- gameplay
- level map
- shop
- screenshots
- ad creative

No random visual styles between screens.

---

# 138. CORE PLAYER FANTASY

The player should feel:

> “I control the bounce.”

Then:

> “I caught the power-up.”

Then:

> “I got multiball.”

Then:

> “That bomb just destroyed everything.”

Then:

> “One more level.”

That is the emotional rhythm we are designing around.

---

# 139. THE MAIN SATISFACTION MOMENT

A perfect Brick Smash moment looks like:

```text
Ball
 ↓
Paddle
 ↓
Brick
 ↓
Brick
 ↓
Power-up
 ↓
MULTIBALL
 ↓
Multiple impacts
 ↓
Bomb
 ↓
Chain reaction
 ↓
Large score
 ↓
LEVEL CLEAR
```

This sequence should feel spectacular without requiring a huge physics simulation.

---

# 140. IMPORTANT BALANCE PRINCIPLE

The game should look **much bigger and more spectacular than it actually is computationally**.

Use:

- particles
- camera effects
- lighting
- sound
- animation
- multiple cosmetic balls
- controlled multiball

to create spectacle.

Do not use massive object counts just to create spectacle.

---

# 141. V1 PERFORMANCE PHILOSOPHY

Prefer:

**5 beautifully simulated objects**

over:

**500 poorly simulated objects.**

Gameplay readability and consistency are more important than raw object count.

---

# 142. FINAL PRODUCT DEFINITION

When someone opens Brick Smash, they should understand within seconds:

> **This is a paddle-controlled brick breaker.**

When someone plays for five minutes, they should discover:

> **Power-ups make the game exciting.**

When someone plays for thirty minutes, they should want:

> **More levels, more stars, more cosmetics.**

When someone sees an advertisement, they should immediately understand:

> **Move the paddle. Keep the ball alive. Smash the bricks.**

---

# 143. NON-NEGOTIABLES

The following are mandatory:

### Gameplay
- paddle-controlled
- level-based
- portrait
- ball and bricks
- finite levels
- lives
- power-ups

### Visual
- polished
- colorful
- arcade
- Brick Smash branding
- 2D gameplay with 2.5D visual treatment

### Technical
- lightweight
- stable 60 FPS target
- scalable level data
- clean architecture
- safe collision handling

### UX
- instant understanding
- minimal onboarding
- dominant Play button
- responsive controls
- satisfying feedback

### Monetization
- conservative ads
- rewarded options
- cosmetic focus
- remove ads option

---

# 144. FINAL DEVELOPMENT COMMAND

Build **Brick Smash** as a polished, lightweight, portrait mobile paddle brick-breaker.

The player controls a paddle horizontally with touch.

The ball bounces automatically.

The player must keep the ball alive while destroying the brick formation.

Bricks have different HP values and special behaviors.

Power-ups create moments of excitement such as multiball, fireball, slow motion and wide paddle.

Bombs and lasers create satisfying chain reactions.

Levels are finite, hand-designed, progressively harder and visually varied.

The interface is modern, colorful and premium-casual.

The game should feel extremely responsive and satisfying while remaining technically lightweight.

Use 2D deterministic gameplay with polished 2.5D presentation.

Do not accidentally revert to the earlier aim-and-fire mega-ball game.

The final experience must be recognizable immediately as:

# BRICK SMASH

**Move the paddle.  
Keep the ball alive.  
Smash every brick.  
Beat the next level.**