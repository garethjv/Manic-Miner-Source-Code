;-----------------------------------------------------------------;
;                                                                 ;
; (C) 1983,1984,1999,2000 Matthew Smith - all rights reserved.    ;
;                                                                 ;
; A Disassembly of Manic Miner for the ZX Spectrum.               ;
;                                                                 ;
; This isn't the original source code written by Matthew Smith.   ;
;                                                                 ;
; It is a disassembly created by William Humphreys with a lot of  ;
; useful help and changes by Simon Brattel. It has been created   ;
; specifically to be assembled with the:                          ;
;                                                                 ;
; Zeus Z80 Assembler / Disassembler / Emulator by Simon Brattal.  ;
;                                                                 ;
; Download: http://www.desdes.com/products/oldfiles/index.htm     ;
;                                                                 ;
; Initially I just wanted to see how the game I had played as a   ;
; young child with one of my first home computers had been        ;
; constructed. After much searching on Google and many downloads  ;
; I couldn't find a version (true to the original) that actually  ;
; compiled. So I decided to create one.                           ;
;                                                                 ;
; The comments in the source are not all my own work but are      ;
; taken from various online resources and non-working files I     ;
; found. The following being the most useful for comments:        ;
;                                                                 ;
; http://skoolkit.ca/disassemblies/manic_miner/index.html         ;
;                                                                 ;
; Manic Miner I'm assuming is still owned by Matthew Smith.       ;
; As there seems to be no way to contact him I'm making the       ;
; assumption that if he sees this and wants it removed he will    ;
; contact me and I will be happy to do so.                        ;
;                                                                 ;
; Github : https://github.com/WHumphreys/Manic-Miner-Source-Code  ;
;                                                                 ;
;                                                                 ;
; Created     : 22 September 2018                                 ;
;                                                                 ;
; Last Update : 22 September 2018                                 ;
;                                                                 ;
;-----------------------------------------------------------------;

sFileName                         equ "ManicMiner"                         ; Used for filenames, etc

; Comment these out if you don't want the files

bGenerateSZX                      equ true                                 ; Generate a *.szx file
; bGenerateZ80                      equ true                                 ; Generate a *.z80 file
; bGenerateTAP                      equ true                                 ; Generate a *.tap file
; bGenerateTZX                      equ true                                 ; Generate a *.tzx file

; Comment this out if you don't want to check the reliability of this source.

; bPerformComparison                equ true                                ; Perform a comparison with the original binary.
                                                                           ; ManicMiner.bin (included with the original)
; Tell Zeus what to emulate

                                  zeusemulate "48K","ULA+"                 ; Set the model and enable ULA+.

; We start using memory immediately after the screen.

                                  ORG $5C00                                ; Start of application

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Attribute Buffer (cavern + Willy + guardians + items).         ;
;                                                                ;
; A buffer for the contents of the attribute buffer at 24064     ;
; (empty cavern),the attributes for Willy, the guardians and     ;
; the items.                                                     ;
;                                                                ;
; ---------------------------------------------------------------;

AttributeBufferCWGI               DEFS 512

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Empty Cavern Attribute Buffer.                                 ;
;                                                                ;
; Initialised upon entry to a cavern and updated throughout      ;
; game.                                                          ;
;                                                                ;
; ---------------------------------------------------------------;

EmptyCavernAttributeBuffer        DEFS 512

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Screen Buffer (cavern + Willy + guardians + items).            ;
;                                                                ;
; Buffer gets initialised with the contents of the screen        ;
; buffer at 28672 (empty cavern), draws Willy, the guardians     ;
; and the items over this background, and then copies the        ;
; result to the display file.                                    ;
; ---------------------------------------------------------------;

ScreenBufferCWGI                  DEFS 4096

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Empty Cavern Screen Buffer.                                    ;
;                                                                ;
; Initialised upon entry to a cavern.                            ;
;                                                                ;
; ---------------------------------------------------------------;

EmptyCavernScreenBuffer           DEFS 4096

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Cavern name.                                                   ;
;                                                                ;
; The cavern name is copied here.                                ;
;                                                                ;
; ---------------------------------------------------------------;

CavernName                        DEFS 32

; ------------------------------------------------------------------------------------------------------------------------------------------;

; --------------------------------------------------------------------;
;                                                                     ;
; Cavern tiles.                                                       ;
;                                                                     ;
; The cavern tiles are copied here and then used to draw the cavern.  ;
; The extra tile behaves like a floor tile, and is used as such       ;
; in The Endorian Forest, Attack of the Mutant Telephones, Ore        ;
; Refinery, Skylab Landing Bay and The Bank. It is also used in The   ;
; Menagerie as spider silk, and in Miner Willy meets the Kong Beast   ;
; and Return of the Alien Kong Beast as a switch.                     ;
;                                                                     ;
; --------------------------------------------------------------------;

BackgroundTile                    DEFS 9                                   ; Background tile
FloorTile                         DEFS 9                                   ; Floor tile
CrumblingFloorTile                DEFS 9                                   ; Crumbling floor tile
WallTile                          DEFS 9                                   ; Wall tile
ConveyorTile                      DEFS 9                                   ; Conveyor tile
NastyTile1                        DEFS 9                                   ; Nasty tile 1
NastyTile2                        DEFS 9                                   ; Nasty tile 2
ExtraTile                         DEFS 9                                   ; Extra tile

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------------;
;                                                                      ;
; Willy's pixel y-coordinate (x2).                                     ;
;                                                                      ;
; Holds the LSB of the address of the entry in the screen buffer       ;
; address lookup table that corresponds to Willy's pixel y-coordinate  ;
; in practice, this is twice Willy's actual pixel y-coordinate.        ;
;                                                                      ;
; ---------------------------------------------------------------------;

WillysPixelYCoord                 DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Willy's animation frame.                                       ;
;                                                                ;
; Initialised upon entry to a cavern or after losing a life and  ;
; updated in game play.                                          ;
;                                                                ;
; Possible values are 0, 1, 2 and 3.                             ;
;                                                                ;
; ---------------------------------------------------------------;

WillysAnimationFrame              DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Willy's direction and movement flags.                          ;
;                                                                ;
; Bit(s) | Meaning                                               ;
; -----------------------------------------------------------    ;
;      0 | Direction Willy is facing (reset=right, set=left)).   ;
;      1 | Willy's movement flag (set=moving).                   ;
;    2-7 | Unused (always reset).                                ;
;                                                                ;
; ---------------------------------------------------------------;

WillysDirAndMovFlags              DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;
; Airborne status indicator.
;
; Value | Meaning
;     0 | Willy is neither falling nor jumping
;     1 | Willy is jumping
;  2-11 | Willy is falling, and can land safely
;   12+ | Willy is falling, and has fallen too far to land safely
;   255 | Willy has collided with a nasty or a guardian

AirborneStatusIndicator           DEFB 0

WillysLocInAttrBuffer             DEFW 0                                   ; Address of Willy's location in the attribute buffer.

JumpingAnimationCounter           DEFB 0                                   ; Jumping animation counter.

; ---------------------------------------------------------------;
;                                                                ;
; Conveyor definitions.                                          ;
;                                                                ;
; ---------------------------------------------------------------;

ConveyorDirection                 DEFB 0                                   ; Direction (0=left, 1=right;)
ConveyorAddress                   DEFW 0                                   ; Address of the conveyor's location in the screen buffer
ConveyorLength                    DEFB 0                                   ; Convayor length.

BorderColor                       DEFB 0                                   ; Border color

; ---------------------------------------------------------------;
;                                                                ;
; Attribute of the last item drawn.                              ;
;                                                                ;
; Holds the attribute byte of the last item drawn, or 0 if all   ;
; the items have been collected.                                 ;
; ---------------------------------------------------------------;

AttrLastItemDrawn                 DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------------------;
;                                                                            ;
; Item definitions.                                                          ;
;                                                                            ;
; Byte(s) | Content                                                          ;
; -------------------------------------------------------------------------  ;
;       0 | Current attribute.                                               ;
;     1,2 | Address of the item's location in the attribute buffer.          ;
;       3 | MSB of the address of the item's location in the screen buffer.  ;
;       4 | Unused (always 255).                                             ;
;                                                                            ;
; ---------------------------------------------------------------------------;

ItemDef1                          DEFS 5                                   ; Item 1.
ItemDef2                          DEFS 5                                   ; Item 2.
ItemDef3                          DEFS 5                                   ; Item 3.
ItemDef4                          DEFS 5                                   ; Item 4.
ItemDef5                          DEFS 5                                   ; Item 5.
ItemDefTerminator                 DEFB 0                                   ; Terminator (set to 255).

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Portal definitions                                             ;
;                                                                ;
; ---------------------------------------------------------------;

PortalDefAttributeByte            DEFB 0                                   ; Attribute byte.
PortalDefGraphicData              DEFS 32                                  ; Graphic data.
PortalDefAttributeBuf             DEFW 0                                   ; Address of the portal's location in the attribute buffer.
PortalDefScreenBuf                DEFW 0                                   ; Address of the portal's location in the screen buffer.

; ------------------------------------------------------------------------------------------------------------------------------------------;

ItemGraphic                       DEFS 8                                   ; Item graphic.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Remaining air supply.                                          ;
;                                                                ;
; Initialised (always to 63 in practice).                        ;
; Its value ranges from 36 to 63 and is actually the LSB of the  ;
; display file address for the cell at the right                 ;
; end of the air bar. The amount of air to draw in this cell is  ;
; determined by the value of the game clock.                     ;
;                                                                ;
; ---------------------------------------------------------------;

RemainingAirSupply                DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Game clock.                                                    ;
;                                                                ;
; Initialised and, updated on every pass through the main loop   ;
; and used for timing purposes.                                  ;
; Its value (which is always a multiple of 4) is also used to    ;
; compute the amount of air to draw in the cell at the right     ;
; end of the air bar.                                            ;
;                                                                ;
; ---------------------------------------------------------------;

GameClock                         DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; --------------------------------------------------------------------------------------------------;
;                                                                                                   ;
; Horizontal guardians.                                                                             ;
;                                                                                                   ;
; Byte | Contents                                                                                   ;
; ------------------------------------------------------------------------------------------------  ;
;    0 | Bit 7: animation speed (0=normal, 1=slow).                                                 ;
;      | Bits 0-6: attribute (BRIGHT, PAPER and INK).                                               ;
;  1,2 | Address of the guardian's location in the attribute buffer.                                ;
;    3 | MSB of the address of the guardian's location in the screen buffer.                        ;
;    4 | Animation frame.                                                                           ;
;    5 | LSB of the address of the leftmost point of the guardian's path in the attribute buffer.   ;
;    6 | LSB of the address of the rightmost point of the guardian's path in the attribute buffer.  ;
;                                                                                                   ;
; --------------------------------------------------------------------------------------------------;

HorizontalGuardian1               DEFS 7                                   ; Horizontal guardian 1.
HorizontalGuardian2               DEFS 7                                   ; Horizontal guardian 2.
HorizontalGuardian3               DEFS 7                                   ; Horizontal guardian 3.
HorizontalGuardian4               DEFS 7                                   ; Horizontal guardian 4.
HorizontalGuardianTerm            DEFB 0                                   ; Terminator (set to 255).

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Eugene's direction or the Kong Beast's status.                 ;
;                                                                ;
; Used to hold Eugene's direction:                               ;
;     0 = Down.                                                  ;
;     1 = Up.                                                    ;
;                                                                ;
; Used to hold the Kong Beast's status:                          ;
;     0 = On the ledge.                                          ;
;     1 = Falling.                                               ;
;     2 = dead.                                                  ;
;                                                                ;
; ---------------------------------------------------------------;

EugDirOrKongBeastStatus           DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------------------------------------------------------;
;                                                                                                               ;
; Various Uses.                                                                                                 ;
;                                                                                                               ;
; Used to hold Eugene's or the Kong Beast's pixel y-coordinate.                                                 ;
; Used to hold the index into the message scrolled across the screen after the theme tune has finished playing. ;
; Used to hold the distance of the boot from the top of the screen as it descends onto Willy.                   ;
; Used to hold Eugene's pixel y-coordinate.                                                                     ;
; Used to hold the Kong Beast's pixel y-coordinate.                                                             ;
;                                                                                                               ;
; ---------------------------------------------------------------------------------------------------------------;

MultiUseCoordinateStore           DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Vertical guardians                                             ;
;                                                                ;
; There are four slots, each one seven bytes long, used to hold  ;
; the state of the vertical guardians in the current cavern.     ;
; For each vertical guardian, the seven bytes are used as        ;
; follows:                                                       ;
;                                                                ;
; Byte | Contents                                                ;
; -----------------------------------                            ;
;    0 | Attribute                                               ;
;    1 | Animation frame                                         ;
;    2 | Pixel y-coordinate                                      ;
;    3 | x-coordinate                                            ;
;    4 | Pixel y-coordinate increment                            ;
;    5 | Minimum pixel y-coordinate                              ;
;    6 | Maximum pixel y-coordinate                              ;
;                                                                ;
; ---------------------------------------------------------------;

; In most of the caverns that do not have vertical guardians, this area is overwritten by unused bytes from the cavern definition.
; The exception is Eugene's Lair: the routine that copies the graphic data for the Eugene sprite into the last 32 bytes of this
; area, where it is then used by a different routine.

VerticalGuardian1                 DEFS 7                                   ; Vertical guardian 1.
VerticalGuardian2                 DEFS 7                                   ; Vertical guardian 2.
VerticalGuardian3                 DEFS 7                                   ; Vertical guardian 3.
VerticalGuardian4                 DEFS 7                                   ; Vertical guardian 4.
VerticalGuardianTerm              DEFB 0                                   ; Terminator (set to 255 in caverns that have four
                                                                           ; vertical guardians).
VerticalGuardianSpare             DEFS 6                                   ; Spare.

; ------------------------------------------------------------------------------------------------------------------------------------------;

GuardianGraphicData               DEFS 256                                 ; Guardian graphic data.

; ------------------------------------------------------------------------------------------------------------------------------------------;

AppFirst                          equ *                                    ; We don't save anything below this byte.

; ---------------------------------------------------------------;
;                                                                ;
; Willy sprite graphic data.                                     ;
;                                                                ;
; ---------------------------------------------------------------;

WillySpriteData                   dg -----##---------
                                  dg --#####---------
                                  dg -#####----------
                                  dg --##-#----------
                                  dg --#####---------
                                  dg --####----------
                                  dg ---##-----------
                                  dg --####----------
                                  dg -######---------
                                  dg -######---------
                                  dg ####-###--------
                                  dg #####-##--------
                                  dg --####----------
                                  dg -###-##---------
                                  dg -##-###---------
                                  dg -###-###--------

                                  dg -------##-------
                                  dg ----#####-------
                                  dg ---#####--------
                                  dg ----##-#--------
                                  dg ----#####-------
                                  dg ----####--------
                                  dg -----##---------
                                  dg ----####--------
                                  dg ---##-###-------
                                  dg ---##-###-------
                                  dg ---##-###-------
                                  dg ---###-##-------
                                  dg ----####--------
                                  dg -----##---------
                                  dg -----##---------
                                  dg -----###--------

WillySpriteData1                  dg ---------##-----
                                  dg ------#####-----
                                  dg -----#####------
                                  dg ------##-#------
                                  dg ------#####-----
                                  dg ------####------
                                  dg -------##-------
                                  dg ------####------
                                  dg -----######-----
                                  dg -----######-----
                                  dg ----####-###----
                                  dg ----#####-##----
                                  dg ------####------
                                  dg -----###-##-----
                                  dg -----##-###-----
                                  dg -----###-###----

WillySpriteData2                  dg -----------##---
                                  dg --------#####---
                                  dg -------#####----
                                  dg --------##-#----
                                  dg --------#####---
                                  dg --------####----
                                  dg ---------##-----
                                  dg --------####----
                                  dg -------######---
                                  dg ------########--
                                  dg -----##########-
                                  dg -----##-####-##-
                                  dg --------#####---
                                  dg -------###-##-#-
                                  dg ------##----###-
                                  dg ------###----#--

                                  dg ---##-----------
                                  dg ---#####--------
                                  dg ----#####-------
                                  dg ----#-##--------
                                  dg ---#####--------
                                  dg ----####--------
                                  dg -----##---------
                                  dg ----####--------
                                  dg ---######-------
                                  dg --########------
                                  dg -##########-----
                                  dg -##-####-##-----
                                  dg ---#####--------
                                  dg -#-##-###-------
                                  dg -###----##------
                                  dg --#----###------

                                  dg -----##---------
                                  dg -----#####------
                                  dg ------#####-----
                                  dg ------#-##------
                                  dg -----#####------
                                  dg ------####------
                                  dg -------##-------
                                  dg ------####------
                                  dg -----######-----
                                  dg -----######-----
                                  dg ----###-####----
                                  dg ----##-#####----
                                  dg ------####------
                                  dg -----##-###-----
                                  dg -----###-##-----
                                  dg ----###-###-----

                                  dg -------##-------
                                  dg -------#####----
                                  dg --------#####---
                                  dg --------#-##----
                                  dg -------#####----
                                  dg --------####----
                                  dg ---------##-----
                                  dg --------####----
                                  dg -------######---
                                  dg -------###-##---
                                  dg -------###-##---
                                  dg -------##-###---
                                  dg --------####----
                                  dg ---------##-----
                                  dg ---------##-----
                                  dg --------###-----

                                  dg ---------##-----
                                  dg ---------#####--
                                  dg ----------#####-
                                  dg ----------#-##--
                                  dg ---------#####--
                                  dg ----------####--
                                  dg -----------##---
                                  dg ----------####--
                                  dg ---------######-
                                  dg ---------######-
                                  dg --------###-####
                                  dg --------##-#####
                                  dg ----------####--
                                  dg ---------##-###-
                                  dg ---------###-##-
                                  dg --------###-###-

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Screen buffer address lookup table.                            ;
;                                                                ;
; The value of the Nth entry (0 <= N <= 127) in this lookup      ;
; tables screen buffer address for the point with pixel          ;
; coordinates (x,y)=(0,N), with the origin (0,0) at the          ;
; top-left corner.                                               ;
;                                                                ;
; ---------------------------------------------------------------;

YTable                            for half=$0000 to $0800 step $0800       ; This is calculated so it works for any buffer address.
                                    for y=$0000 to $00E0 step $0020        ; (in theory)
                                      for x=$0000 to $0700 step $0100
                                        dw ScreenBufferCWGI+x+y+half
                                      next
                                    next
                                  next

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; ******************        Load Game        ******************  ;
;                                                                ;
; ---------------------------------------------------------------;

AppEntry                DI                                                 ; Disable interrupts.
                        LD SP,MemTop                                       ; Place the stack somewhere safe.
                        JP Start                                           ; Display the title screen and play the theme tune.

; ------------------------------------------------------------------------------------------------------------------------------------------;

CurrentCavernNumber     DEFB 0                                             ; Current cavern number.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Left-right movement table.                                     ;
;                                                                ;
; The entries in this table are used to map the existing value   ;
; (V) of Willy's direction and movement flags at 32874 to a new  ;
; value (V'), depending on the direction Willy is facing and     ;
; how he is moving or being moved (by 'left' and 'right'         ;
; keypresses and joystick input, or by a conveyor).              ;
;                                                                ;
; ---------------------------------------------------------------;

; One of the first four entries is used when Willy is not moving.

WillyNotMoving0                   DEFB 0  ; V=0 (facing right, no movement) + no movement: V'=0 (no change).
WillyNotMoving1                   DEFB 1  ; V=1 (facing left, no movement) + no movement: V'=1 (no change).
WillyNotMoving2                   DEFB 0  ; V=2 (facing right, moving) + no movement: V'=0 (facing right, no movement) (i.e. stop).
WillyNotMoving3                   DEFB 1  ; V=3 (facing left, moving) + no movement: V'=1 (facing left, no movement) (i.e. stop).

; One of the next four entries is used when Willy is moving left.

WillyMovingLeft0                  DEFB 1  ; V=0 (facing right, no movement) + move left: V'=1 (facing left, no movement) (i.e. turn around).
WillyMovingLeft1                  DEFB 3  ; V=1 (facing left, no movement) + move left: V'=3 (facing left, moving).
WillyMovingLeft2                  DEFB 1  ; V=2 (facing right, moving) + move left: V'=1 (facing left, no movement) (i.e. turn around).
WillyMovingLeft3                  DEFB 3  ; V=3 (facing left, moving) + move left: V'=3 (no change).

; One of the next four entries is used when Willy is moving right.

WillyMovingRight0                 DEFB 2  ; V=0 (facing right, no movement) + move right: V'=2 (facing right, moving).
WillyMovingRight1                 DEFB 0  ; V=1 (facing left, no movement) + move right: V'=0 (facing right, no movement) (i.e. turn around).
WillyMovingRight2                 DEFB 2  ; V=2 (facing right, moving) + move right: V'=2 (no change).
WillyMovingRight3                 DEFB 0  ; V=3 (facing left, moving) + move right: V'=0 (facing right, no movement) (i.e. turn around).

; One of the final four entries is used when Willy is being pulled both left and right; each entry leaves the flags unchanged
; (so Willy carries on moving in the direction he's already moving, or remains stationary).

WillyMovingBoth0                  DEFB 0  ; V=V'=0 (facing right, no movement).
WillyMovingBoth1                  DEFB 1  ; V=V'=1 (facing left , no movement).
WillyMovingBoth2                  DEFB 2  ; V=V'=2 (facing right, moving).
WillyMovingBoth3                  DEFB 3  ; V=V'=3 (facing left , moving).

; ------------------------------------------------------------------------------------------------------------------------------------------;

AirText                           DEFM "AIR"                               ; 'AIR'.
                                  DEFM "0000"                              ; UNUSED.
HighScore                         DEFM "000000"                            ; High Score.

; Score

Score1                            DEFM "0"                                 ; Overflow digits (these may be updated, but are never printed).
Score2                            DEFM "000000000"


HighScoreText                     DEFM "High Score 000000   Score 000000"

GameText                          DEFM "Game"
OverText                          DEFM "Over"

LivesRemaining                    DEFB 0                                   ; Lives remaining.
ScreenFlashCounter                DEFB 0                                   ; Screen flash counter.
KempJoystickIndicator             DEFB 0                                   ; Kempston joystick indicator Holds 1 if a joystick is present,
                                                                           ; 0 otherwise.
GameModeIndicator                 DEFB 0                                   ; Holds 0 when a game is in progress, or a value from 1 to 64
                                                                           ; when in demo mode.
MusicNoteIndex                    DEFB 0                                   ; In-game music note index.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------------------;
;                                                                            ;
; Music flags.                                                               ;
;                                                                            ;
; Bit(s) | Meaning                                                           ;
; -------------------------------------------------------------------------  ;
;      0 | Keypress flag (set=H-ENTER being pressed, reset=no key pressed).  ;
;      1 | In-game music flag (set=music off, reset=music on).               ;
;    2-7 | Unused.                                                           ;
;                                                                            ;
; ---------------------------------------------------------------------------;

MusicFlags                        DEFB 0

; ------------------------------------------------------------------------------------------------------------------------------------------;

KeyCounter                        DEFB 0                                   ; 6031769 Key counter.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; 6031769 (Cheat Codes).                                         ;
;                                                                ;
; In each pair of bytes here, bits 0-4 of the first byte         ;
; correspond to keys 1-2-3-4-5, and bits 0-4 of the second byte  ;
; correspond to keys 0-9-8-7-6; among those bits, a zero         ;
; indicates a key being pressed.                                 ;
;                                                                ;
; ---------------------------------------------------------------;

KP6031769xN                       DEFB %00011111,%00011111                 ; (no keys pressed)
KP6031769x6                       DEFB %00011111,%00001111                 ; 6
KP6031769x0                       DEFB %00011111,%00011110                 ; 0
KP6031769x3                       DEFB %00011011,%00011111                 ; 3
KP6031769x1                       DEFB %00011110,%00011111                 ; 1
KP6031769x7                       DEFB %00011111,%00010111                 ; 7
KP6031769xx6                      DEFB %00011111,%00001111                 ; 6
KP6031769x9                       DEFB %00011111,%00011101                 ; 9


; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Title screen tune data (The Blue Danube).                      ;
;                                                                ;
; The tune data is organised into 95 groups of three bytes       ;
; each, one group for each note in the tune. The first byte in   ;
; each group determines the duration of the note, and the        ;
; second and third bytes determine the frequency (and also the   ;
; piano keys that light up).                                     ;
;                                                                ;
; ---------------------------------------------------------------;

TitleScreenTuneData               DEFB 80,128,129
                                  DEFB 80,102,103
                                  DEFB 80,86,87
                                  DEFB 50,86,87
                                  DEFB 50,171,203
                                  DEFB 50,43,51
                                  DEFB 50,43,51
                                  DEFB 50,171,203
                                  DEFB 50,51,64
                                  DEFB 50,51,64
                                  DEFB 50,171,203
                                  DEFB 50,128,129
                                  DEFB 50,128,129
                                  DEFB 50,102,103
                                  DEFB 50,86,87
                                  DEFB 50,96,86
                                  DEFB 50,171,192
                                  DEFB 50,43,48
                                  DEFB 50,43,48
                                  DEFB 50,171,192
                                  DEFB 50,48,68
                                  DEFB 50,48,68
                                  DEFB 50,171,192
                                  DEFB 50,136,137
                                  DEFB 50,136,137
                                  DEFB 50,114,115
                                  DEFB 50,76,77
                                  DEFB 50,76,77
                                  DEFB 50,171,192
                                  DEFB 50,38,48
                                  DEFB 50,38,48
                                  DEFB 50,171,192
                                  DEFB 50,48,68
                                  DEFB 50,48,68
                                  DEFB 50,171,192
                                  DEFB 50,136,137
                                  DEFB 50,136,137
                                  DEFB 50,114,115
                                  DEFB 50,76,77
                                  DEFB 50,76,77
                                  DEFB 50,171,203
                                  DEFB 50,38,51
                                  DEFB 50,38,51
                                  DEFB 50,171,203
                                  DEFB 50,51,64
                                  DEFB 50,51,64
                                  DEFB 50,171,203
                                  DEFB 50,128,129
                                  DEFB 50,128,129
                                  DEFB 50,102,103
                                  DEFB 50,86,87
                                  DEFB 50,64,65
                                  DEFB 50,128,171
                                  DEFB 50,32,43
                                  DEFB 50,32,43
                                  DEFB 50,128,171
                                  DEFB 50,43,51
                                  DEFB 50,43,51
                                  DEFB 50,128,171
                                  DEFB 50,128,129
                                  DEFB 50,128,129
                                  DEFB 50,102,103
                                  DEFB 50,86,87
                                  DEFB 50,64,65
                                  DEFB 50,128,152
                                  DEFB 50,32,38
                                  DEFB 50,32,38
                                  DEFB 50,128,152
                                  DEFB 50,38,48
                                  DEFB 50,38,48
                                  DEFB 50,0,0
                                  DEFB 50,114,115
                                  DEFB 50,114,115
                                  DEFB 50,96,97
                                  DEFB 50,76,77
                                  DEFB 50,76,153
                                  DEFB 50,76,77
                                  DEFB 50,76,77
                                  DEFB 50,76,153
                                  DEFB 50,91,92
                                  DEFB 50,86,87
                                  DEFB 50,51,205
                                  DEFB 50,51,52
                                  DEFB 50,51,52
                                  DEFB 50,51,205
                                  DEFB 50,64,65
                                  DEFB 50,102,103
                                  DEFB 100,102,103
                                  DEFB 50,114,115
                                  DEFB 100,76,77
                                  DEFB 50,86,87
                                  DEFB 50,128,203
                                  DEFB 25,128,0
                                  DEFB 25,128,129
                                  DEFB 50,128,203
                                  DEFB $FF                                 ; End marker

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; In-game tune data (In the Hall of the Mountain King).          ;
;                                                                ;
; ---------------------------------------------------------------;

InGameTuneData                    DEFB 128,114,102,96,86,102,86,86,81,96,81,81,86,102,86,86
                                  DEFB 128,114,102,96,86,102,86,86,81,96,81,81,86,86,86,86
                                  DEFB 128,114,102,96,86,102,86,86,81,96,81,81,86,102,86,86
                                  DEFB 128,114,102,96,86,102,86,64,86,102,128,102,86,86,86,86

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Display the title screen and play the theme tune               ;
;                                                                ;
; The first thing this routine does is initialise some game      ;
; status buffer variables in preparation for the next game.      ;
;                                                                ;
; ---------------------------------------------------------------;

Start                             XOR A                                    ; A=0.
                                  LD (CurrentCavernNumber),A               ; Initialise the current cavern number.
                                  LD (KempJoystickIndicator),A             ; Initialise the Kempston joystick indicator.
                                  LD (GameModeIndicator),A                 ; Initialise the game mode indicator.
                                  LD (MusicNoteIndex),A                    ; Initialise the in-game music note index.
                                  LD (ScreenFlashCounter),A                ; Initialise the screen flash counter.
                                  LD A,2
                                  LD (LivesRemaining),A                    ; Initialise the number of lives remaining.
                                  LD HL,MusicFlags
                                  SET 0,(HL)                               ; Initialise the keypress flag in bit 0.

; Next, prepare the screen.

                                  LD HL,16384                              ; Clear the entire display file.
                                  LD DE,16385
                                  LD BC,6143
                                  LD (HL),0
                                  LDIR
                                  LD HL,TitleScreenDataTop                 ; Copy the graphic data to the top two-thirds of the display
                                                                           ; file.
                                  LD DE,16384
                                  LD BC,4096
                                  LDIR
                                  LD HL,18493                              ; Draw Willy at (9,29).
                                  LD DE,WillySpriteData1
                                  LD C,0
                                  CALL DrawASprite
                                  LD HL,TheFinalBarrierData                ; Copy the attribute bytes to the top third of the attribute
                                                                           ; file.
                                  LD DE,22528
                                  LD BC,256
                                  LDIR
                                  LD HL,BottomAttributes                   ; Copy the attribute bytes to the bottom two-thirds of the
                                                                           ; attribute file.
                                  LD BC,512
                                  LDIR

; Now check whether there is a joystick connected.

                                  LD BC,31                                 ; This is the joystick port
                                  DI                                       ; Disable interrupts (which are already disabled)
                                  XOR A                                    ; A=0
Start2                            IN E,(C)                                 ; Combine 256 readings of the joystick port in A; if no
                                                                           ; joystick is connected, some of these readings will have bit
                                                                           ; 5 set.
                                  OR E
                                  DJNZ Start2
                                  AND $20                                  ; Is a joystick connected (bit 5 reset)?
                                  JR NZ,Start3                             ; Jump if not.
                                  LD A,1                                   ; Set the Kempston joystick indicator to 1.
                                  LD (KempJoystickIndicator),A

; And finally, play the theme tune and check for keypresses.

Start3                            LD IY,TitleScreenTuneData                ; Point IY at the theme tune data.
                                  CALL PlayTheThemeTune                    ; Play the theme tune.
                                  JP NZ,Start6                             ; Start the game if ENTER or the fire button was pressed.

                                  XOR A                                    ; Initialise the game status buffer variable.
                                  LD (MultiUseCoordinateStore),A           ; this will be used as an index for the message scrolled across.
                                                                           ; the screen.
Start4                            LD A,(MultiUseCoordinateStore)           ; Pick up the message index.
                                  LD IX,TitleScreenBanner                  ; Point IX at the corresponding location in the message
                                                                           ; (TitleScreenBanner + MultiUseCoordinateStore).
                                  LD IXL,a
                                  LD DE,20576                              ; Print 32 characters of the message at (19,0).
                                  LD C,32
                                  CALL PrintAMessage
                                  LD A,(MultiUseCoordinateStore)           ; Pick up the message index
                                  AND 6                                    ; Keep only bits 1 and 2, and move them into bits 6 and 7, so
                                                                           ; that A holds 0, 64, 128 or 192;
                                  RRCA                                     ; This value determines the animation frame to use for Willy.
                                  RRCA
                                  RRCA
                                  LD E,A
                                  LD D,high WillySpriteData                ; Point DE at the graphic data for Willy's sprite.
                                                                           ; (WillySpriteData + A).
                                  LD HL,18493                              ; Draw Willy at (9,29).
                                  LD C,0
                                  CALL DrawASprite
                                  LD BC,100                                ; Pause for about 0.1s.
Start5                            DJNZ Start5
                                  DEC C
                                  JR NZ,Start5
                                  LD BC,zeuskeyaddr("HJKL[ENTER]")         ; Read keys H-J-K-L-ENTER.
                                  IN A,(C)
                                  AND 1                                    ; Keep only bit 0 of the result (ENTER).
                                  CP 1                                     ; Is ENTER being pressed?
                                  JR NZ,Start6                             ; If so, start the game.
                                  LD A,(MultiUseCoordinateStore)           ; Pick up the message index.
                                  INC A                                    ; Increment it.
                                  CP 224                                   ; Set the zero flag if we've reached the end of the message.
                                  LD (MultiUseCoordinateStore),A           ; Store the new message index.
                                  JR NZ,Start4                             ; Jump back unless we've finished scrolling the message across
                                                                           ; the screen.
                                  LD A,64                                  ; Initialise the game mode indicator to 64: demo mode.
                                  LD (GameModeIndicator),A

; Start the game (or demo mode).

Start6                            LD HL,Score1                             ; Initialise the score.
                                  LD DE,Score2
                                  LD BC,9
                                  LD (HL),48
                                  LDIR

; This entry point is used when teleporting into a cavern or reinitialising the current cavern after Willy has lost a life.

Start7                            LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  SLA A                                    ; (*2) Point HL at the first byte of the cavern definition
                                  SLA A                                    ; (*4)
                                  ADD A,high CentralCavernData             ; Add the base of all the cavern data
                                  LD H,A                                   ; Point HL at the first byte of the cavern definition.
                                  LD L,0
                                  LD DE,EmptyCavernAttributeBuffer         ; Copy the cavern's attribute bytes into the buffer.
                                  LD BC,512
                                  LDIR
                                  LD DE,CavernName                         ; Copy the rest of the cavern definition into the
                                  LD BC,512                                ; game status buffer.
                                  LDIR
                                  CALL DrawCurrentCavernToScreenBuffer     ; Draw the current cavern to the screen buffer.
                                  LD HL,20480                              ; Clear the bottom third of the display file.
                                  LD DE,20481
                                  LD BC,2047
                                  LD (HL),0
                                  LDIR
                                  LD IX,CavernName                         ; Print the cavern name at (16,0).
                                  LD C,32
                                  LD DE,20480
                                  CALL PrintAMessage
                                  LD IX,AirText                            ; Print 'AIR' at (17,0).
                                  LD C,3
                                  LD DE,20512
                                  CALL PrintAMessage
                                  LD A,82                                  ; Initialise A to 82; this is the MSB of the display file
                                                                           ; address at which to start drawing the bar that represents
                                                                           ; the air supply.
Start8                            LD H,A                                   ; Prepare HL and DE for drawing a row of pixels in the air bar.
                                  LD D,A
                                  LD L,36
                                  LD E,37
                                  LD B,A                                   ; Save the display file address MSB in B briefly.
                                  LD A,(RemainingAirSupply)                ; Pick up the value of the initial air supply.
                                  SUB 36                                   ; Now C determines the length of the air bar (in cell widths).
                                  LD C,A
                                  LD A,B                                   ; Restore the display file address MSB to A.
                                  LD B,0                                   ; Now BC determines the length of the air bar (in cell widths).
                                  LD (HL),$FF                              ; Draw a single row of pixels across C cells.
                                  LDIR
                                  INC A                                    ; Increment the display file address MSB in A
                                                                           ; (moving down to the next row of pixels).
                                  CP 86                                    ; Have we drawn all four rows of pixels in the air bar yet?
                                  JR NZ,Start8                             ; If not, jump back to draw the next one.
                                  LD IX,HighScoreText                      ; Print 'High Score 000000   Score 000000' at (19,0).
                                  LD DE,20576
                                  LD C,32
                                  CALL PrintAMessage
                                  LD A,(BorderColor)                       ; Pick up the border colour for the current cavern.
                                  LD C,254                                 ; Set the border colour.
                                  OUT (C),A
                                  LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Are we in demo mode?
                                  JR Z,MainLoop                            ; If not, enter the main loop now.
                                  LD A,64                                  ; Reset the game mode indicator to 64 (we're in demo mode).
                                  LD (GameModeIndicator),A

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Main loop                                                      ;
;                                                                ;
; ---------------------------------------------------------------;

MainLoop                          LD A,(LivesRemaining)                    ; Pick up the number of lives remaining.
                                  LD HL,20640                              ; Set HL to the display file address at which to draw the first
                                  ; Willy sprite.
                                  OR A                                     ; Are there any lives remaining?
                                  JR Z,MainLoop3                           ; Jump if not.
                                  LD B,A                                   ; Initialise B to the number of lives remaining.

; The following loop draws the remaining lives at the bottom of the screen.

MainLoop2                         LD C,0                                   ; C=0; this tells the sprite-drawing routine to overwrite any
                                                                           ; existing graphics.
                                  PUSH HL                                  ; Save HL and BC briefly.
                                  PUSH BC
                                  LD A,(MusicNoteIndex)                    ; Pick up the in-game music note index this will determine the
                                                                           ; animation frame for the Willy sprites.
                                  RLCA                                     ; Now A=0 (frame 0), 32 (frame 1), 64 (frame 2) or 96
                                  RLCA                                     ; (frame 3).
                                  RLCA
                                  AND $60
                                  LD E,A                                   ; Point DE at the corresponding Willy sprite
                                  LD D,high WillySpriteData                ; (at WillySpriteData + A).
                                  CALL DrawASprite                         ; Draw the Willy sprite on the screen.
                                  POP BC                                   ; Restore HL and BC.
                                  POP HL
                                  INC HL                                   ; Move HL along to the location at which to draw the next
                                  INC HL                                   ; Willy sprite.
                                  DJNZ MainLoop2                           ; Jump back to draw any remaining sprites.

; Now draw a boot if cheat mode has been activated.

MainLoop3                         LD A,(KeyCounter)                        ; Pick up the 6031769 key counter.
                                  CP 7                                     ; Has 6031769 been keyed in yet?
                                  JR NZ,MainLoop4                          ; Jump if not.
                                  LD DE,BootGraphicData                    ; Point DE at the graphic data for the boot.
                                  LD C,0                                   ; C=0 (overwrite mode).
                                  CALL DrawASprite                         ; Draw the boot at the bottom of the screen next to the
                                                                           ; remaining lives.

; Next, prepare the screen and attribute buffers for drawing to the screen.

MainLoop4                         LD HL,EmptyCavernAttributeBuffer         ; Copy the contents of the attribute buffer.
                                                                           ; (the attributes for the empty cavern).
                                  LD DE,AttributeBufferCWGI                ; Into the attribute buffer at AttributeBufferCWGI.
                                  LD BC,512
                                  LDIR
                                  LD HL,EmptyCavernScreenBuffer            ; Copy the contents of the screen buffer.
                                                                           ; (the tiles for the empty cavern).
                                  LD DE,ScreenBufferCWGI                   ; Into the screen buffer at ScreenBufferCWGI.
                                  LD BC,4096
                                  LDIR
                                  CALL MoveHorzGuardians                   ; Move the horizontal guardians in the current cavern.
                                  LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Are we in demo mode?
                                  CALL Z,MoveWilly1                        ; If not, move Willy.
                                  LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Are we in demo mode?
                                  CALL Z,CheckSetAttributeForWSIB          ; If not, check and set the attribute bytes for Willy's sprite.
                                                                           ; in the buffer at 23552,and draw Willy to the screen buffer
                                                                           ; at 24576.
                                  CALL DrawHorzontalGuardians              ; Draw the horizontal guardians in the current cavern.
                                  CALL MoveConveyorInTheCurrentCavern      ; Move the conveyor in the current cavern.
                                  CALL DrawCollectItemsWillyTouching       ; Draw the items in the current cavern and collect any that
                                                                           ; Willy is touching.
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  CP 4                                     ; Are we in Eugene's Lair?
                                  CALL Z,MoveDrawEugene                    ; If so, move and draw Eugene.
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  CP 13                                    ; Are we in Skylab Landing Bay?
                                  JP Z,MoveDrawSkyLabs                     ; If so, move and draw the Skylabs.
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  CP 8                                     ; Are we in Wacky Amoebatrons or beyond?
                                  CALL NC,MoveDrawVerticalGuardians        ; If so, move and draw the vertical guardians.
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern
                                  CP 7                                     ; Are we in Miner Willy meets the Kong Beast?
                                  CALL Z,MoveDrawKongBeast                 ; If so, move and draw the Kong Beast
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern
                                  CP 11                                    ; Are we in Return of the Alien Kong Beast?
                                  CALL Z,MoveDrawKongBeast                 ; If so, move and draw the Kong Beast
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  CP 18                                    ; Are we in Solar Power Generator?
                                  CALL Z,MoveDrawLightBeam                 ; If so, move and draw the light beam
MainLoop5                         CALL DrawThePortal                       ; Draw the portal, or move to the next cavern if Willy has
                                                                           ; entered it.
MainLoop6                         LD HL,ScreenBufferCWGI                   ; Copy the contents of the screen buffer at ScreenBufferCWGI to
                                                                           ; the display file.
                                  LD DE,16384
                                  LD BC,4096
                                  LDIR
                                  LD A,(ScreenFlashCounter)                ; Pick up the screen flash counter from ScreenFlashCounter.
                                  OR A                                     ; Is it zero?
                                  JR Z,MainLoop7                           ; Jump if so
                                  DEC A                                    ; Decrement the screen flash counter at ScreenFlashCounter.
                                  LD (ScreenFlashCounter),A
                                  RLCA                                     ; Move bits 0-2 into bits 3-5 and clear all the other bits.
                                  RLCA
                                  RLCA
                                  AND $38
                                  LD HL,AttributeBufferCWGI                ; Set every attribute byte in the buffer at AttributeBufferCWGI
                                  LD DE,AttributeBufferCWGI+1              ; to this value.
                                  LD BC,511
                                  LD (HL),A
                                  LDIR
MainLoop7                         LD HL,AttributeBufferCWGI                ; Copy the contents of the attribute buffer at
                                  LD DE,22528                              ; AttributeBufferCWGI to the attribute file.
                                  LD BC,512
                                  LDIR
                                  LD IX,Score2+3                           ; Print the score (Score2 + 3) at (19,26).
                                  LD DE,20602
                                  LD C,6
                                  CALL PrintAMessage
                                  LD IX,HighScore                          ; Print the high score HighScore at (19,11).
                                  LD DE,20587
                                  LD C,6
                                  CALL PrintAMessage
                                  CALL DecreaseAirRemaining                ; Decrease the air remaining in the current cavern.
                                  JP Z,MainLoop19

; Now check whether SHIFT and SPACE are being pressed.

                                  LD BC,zeuskeyaddr("[SHIFT]ZXCV")         ; Read keys SHIFT-Z-X-C-V.
                                  IN A,(C)
                                  LD E,A                                   ; Save the result in E.
                                  LD B,high zeuskeyaddr("BNM[SYM][SPACE]") ; Read keys B-N-M-SS-SPACE.
                                  IN A,(C)
                                  OR E                                     ; Combine the results.
                                  AND 1                                    ; Are SHIFT and SPACE being pressed?
                                  JP Z,Start                               ; If so, quit the game.

; Now read the keys A, S, D, F and G (which pause the game).

                                  LD B,high zeuskeyaddr("ASDFG")           ; Read keys A-S-D-F-G.
                                  IN A,(C)                                 ;
                                  AND $1F                                  ; Are any of these keys being pressed?
                                  CP $1F                                   ;
                                  JR Z,MainLoop9                           ; Jump if not.
MainLoop8                         LD B,(high zeuskeyaddr("ASDFG")) xor $FF ; Read every half-row of keys except A-S-D-F-G.
                                  IN A,(C)
                                  AND $1F                                  ; Are any of these keys being pressed?
                                  CP $1F
                                  JR Z,MainLoop8                           ; Jump back if not (the game is still paused).

; Here we check whether Willy has had a fatal accident.

MainLoop9                         LD A,(AirborneStatusIndicator)           ; Pick up the airborne status indicator
                                  CP $FF                                   ; Has Willy landed after falling from too great a height, or
                                                                           ; collided with a nasty or a guardian?
                                  JP Z,MainLoop19                          ; Jump if so.

; Now read the keys H, J, K, L and ENTER (which toggle the in-game music).

                                  LD B,high zeuskeyaddr("HJKL[ENTER]")     ; Prepare B for reading keys H-J-K-L-ENTER
                                  LD HL,MusicFlags                         ; Point HL at the music flags
                                  IN A,(C)                                 ; Read keys H-J-K-L-ENTER
                                  AND $1F                                  ; Are any of these keys being pressed?
                                  CP $1F
                                  JR Z,MainLoop10                          ; Jump if not
                                  BIT 0,(HL)                               ; Were any of these keys being pressed the last time we checked?
                                  JR NZ,MainLoop11                         ; Jump if so
                                  LD A,(HL)                                ; Set bit 0 (the keypress flag) and flip bit 1
                                  XOR 3                                    ; (the in-game music flag).
                                  LD (HL),A
                                  JR MainLoop11
MainLoop10                        RES 0,(HL)                               ; Reset bit 0 (the keypress flag).
MainLoop11                        BIT 1,(HL)                               ; Has the in-game music been switched off?
                                  JR NZ,MainLoop14                         ; Jump if so.

; The next section of code plays a note of the in-game music.

                                  LD A,(MusicNoteIndex)                    ; Increment the in-game music note index.
                                  INC A
                                  LD (MusicNoteIndex),A
                                  AND 126
                                  RRCA
                                  LD E,A
                                  LD D,0
                                  LD HL,InGameTuneData                     ; Point HL at the appropriate entry in the tune data table at
                                  ADD HL,DE                                ; InGameTuneData.
                                  LD A,(BorderColor)                       ; Pick up the border colour for the current cavern.
                                  LD E,(HL)                                ; Initialise the pitch delay counter in E.
                                  LD BC,3                                  ; Initialise the duration delay counters in B (0) and C (3).
MainLoop12                        OUT (254),A                              ; Produce a note of the in-game music.
                                  DEC E
                                  JR NZ,MainLoop13
                                  LD E,(HL)
                                  XOR 24
MainLoop13                        DJNZ MainLoop12
                                  DEC C
                                  JR NZ,MainLoop12

; If we're in demo mode, check the keyboard and joystick and return to the title screen if there's any input.

MainLoop14                        LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Are we in demo mode?
                                  JR Z,MainLoop15                          ; Jump if not.
                                  DEC A                                    ; We're in demo mode; is it time to show the next cavern?
                                  JP Z,MainLoop19                          ; Jump if so.
                                  LD (GameModeIndicator),A                 ; Update the game mode indicator.
                                  LD BC,$00FE                              ; Read every row of keys on the keyboard.
                                  IN A,(C)
                                  AND $1F                                  ; Are any keys being pressed?
                                  CP $1F
                                  JP NZ,Start                              ; If so, return to the title screen.
                                  LD A,(KempJoystickIndicator)             ; Pick up the Kempston joystick indicator.
                                  OR A                                     ; Is there a joystick connected?
                                  JR Z,MainLoop15                          ; Jump if not.
                                  IN A,(31)                                ; Collect input from the joystick.
                                  OR A                                     ; Is the joystick being moved or the fire button being pressed?
                                  JP NZ,Start                              ; If so, return to the title screen.

; Here we check the teleport keys.

MainLoop15                        LD BC,zeuskeyaddr("67890")               ; Read keys 6-7-8-9-0.
                                  IN A,(C)
                                  BIT 4,A                                  ; Is '6' (the activator key) being pressed?
                                  JP NZ,MainLoop16                         ; Jump if not.
                                  LD A,(KeyCounter)                        ; Pick up the 6031769 key counter.
                                  CP 7                                     ; Has 6031769 been keyed in yet?
                                  JP NZ,MainLoop16                         ; Jump if not.
                                  LD B,high zeuskeyaddr("12345")           ; Read keys 1-2-3-4-5.
                                  IN A,(C)
                                  CPL                                      ; Keep only bits 0-4 and flip them.
                                  AND $1F
                                  CP 20                                    ; Is the result 20 or greater?
                                  JP NC,MainLoop16                         ; Jump if so (this is not a cavern number).
                                  LD (CurrentCavernNumber),A               ; Store the cavern number.
                                  JP Start7                                ; Teleport into the cavern.

; Now check the 6031769 keys.

MainLoop16                        LD A,(KeyCounter)                        ; Pick up the 6031769 key counter.
                                  CP 7                                     ; Has 6031769 been keyed in yet?
                                  JP Z,MainLoop                            ; If so, jump back to the start of the main loop.
                                  RLCA
                                  LD E,A
                                  LD D,0
                                  LD IX,KP6031769x6                        ; Point IX at the corresponding entry in the 6031769 table at
                                  ADD IX,DE                                ; KP6031769x6.
                                  LD BC,zeuskeyaddr("12345")               ; Read keys 1-2-3-4-5.
                                  IN A,(C)
                                  AND $1F                                  ; Keep only bits 0-4.
                                  CP (IX+0)                                ; Does this match the first byte of the entry in the 6031769
                                                                           ; table?
                                  JR Z,MainLoop17                          ; Jump if so.
                                  CP $1F                                   ; Are any of the keys 1-2-3-4-5 being pressed?
                                  JP Z,MainLoop                            ; If not, jump back to the start of the main loop.
                                  CP (IX-2)                                ; Does the keyboard reading match the first byte of the
                                                                           ; previous entry?
                                  JP Z,MainLoop                            ; If so, jump back to the start of the main loop.
                                  XOR A                                    ; Reset the 6031769 key counter at KeyCounter to 0
                                  LD (KeyCounter),A                        ; (an incorrect key is being pressed).
                                  JP MainLoop                              ; Jump back to the start of the main loop.
MainLoop17                        LD B,high zeuskeyaddr("67890")           ; Read keys 6-7-8-9-0.
                                  IN A,(C)
                                  AND $1F                                  ; Keep only bits 0-4.
                                  CP (IX+1)                                ; Does this match the second byte of the entry in the 6031769
                                                                           ; table?
                                  JR Z,MainLoop18                          ; If so, jump to increment the 6031769 key counter.
                                  CP $1F                                   ; Are any of the keys 6-7-8-9-0 being pressed?
                                  JP Z,MainLoop                            ; If not, jump back to the start of the main loop.
                                  CP (IX-1)                                ; Does the keyboard reading match the second byte of the
                                                                           ; previous entry?
                                  JP Z,MainLoop                            ; If so, jump back to the start of the main loop.
                                  XOR A                                    ; Reset the 6031769 key counter at KeyCounter to 0
                                  LD (KeyCounter),A                        ; (an incorrect key is being pressed).
                                  JP MainLoop                              ; Jump back to the start of the main loop.
MainLoop18                        LD A,(KeyCounter)                        ; Increment the 6031769 key counter at KeyCounter
                                                                           ; (the next key in the sequence is being pressed).
                                  INC A
                                  LD (KeyCounter),A
                                  JP MainLoop                              ; Jump back to the start of the main loop.

; The air in the cavern has run out, or Willy has had a fatal accident, or it's demo mode and it's time to show the next cavern.

MainLoop19                        LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Is it demo mode?
                                  JP NZ,MoveToTheNextCavern                ; If so, move to the next cavern
                                  LD A,$47                                 ; A=71 (INK 7: PAPER 0: BRIGHT 1)

; The following loop fills the top two thirds of the attribute file with a single value
; (71, 70, 69, 68, 67, 66, 65 or 64) and makes a sound effect.

MainLoop20                        LD HL,22528                              ; Fill the top two thirds of the attribute file with the value
                                  LD DE,22529                              ; in A.
                                  LD BC,511
                                  LD (HL),A
                                  LDIR
                                  LD E,A                                   ; Save the attribute byte (64-71) in E for later retrieval
                                  CPL                                      ; D=63-8*(E AND 7); this value determines the pitch of the short
                                  AND 7                                    ; note that will be played.
                                  RLCA
                                  RLCA
                                  RLCA
                                  OR 7
                                  LD D,A
                                  LD C,E                                   ; C=8+32*(E AND 7); this value determines the duration of the
                                  RRC C                                    ; short note that will be played.
                                  RRC C
                                  RRC C
                                  OR 16                                    ; Set bit 4 of A (for no apparent reason).
                                  XOR A                                    ; Set A=0 (this will make the border black).
MainLoop21                        OUT (254),A                              ; Produce a short note whose pitch is determined by D.
                                  XOR 24                                   ; and whose duration is determined by C.
                                  LD B,D
                                  DJNZ .
                                  DEC C
                                  JR NZ,MainLoop21
                                  LD A,E                                   ; Restore the attribute byte (originally 71) to A.
                                  DEC A                                    ; Decrement it (effectively decrementing the INK colour).
                                  CP 63                                    ; Have we used attribute value 64 (INK 0) yet?
                                  JR NZ,MainLoop20                         ; If not, jump back to update the INK colour in the top two
                                                                           ; thirds of the screen and make another sound effect.

; Finally, check whether any lives remain.

                                  LD HL,LivesRemaining                     ; Pick up the number of lives remaining.
                                  LD A,(HL)                                ;
                                  OR A                                     ; Are there any lives remaining?
                                  JP Z,DisplayGameOver                     ; If not, display the game over sequence.
                                  DEC (HL)                                 ; Decrease the number of lives remaining by one.
                                  JP Start7                                ; Jump back to reinitialise the current cavern.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Display the game over sequence                                 ;
;                                                                ;
; First check whether we have a new high score.                  ;
;                                                                ;
; ---------------------------------------------------------------;

; First check whether we have a new high score.

DisplayGameOver                   LD HL,HighScore                          ; Point HL at the high score.
                                  LD DE,Score2+3                           ; Point DE at the current score.
                                  LD B,6                                   ; There are 6 digits to compare.
DisplayGameOver2                  LD A,(DE)                                ; Pick up a digit of the current score .
                                  CP (HL)                                  ; Compare it with the corresponding digit of the high score.
                                  JP C,DisplayGameOver4                    ; Jump if it's less than the corresponding digit of the high
                                                                           ; score.
                                  JP NZ,DisplayGameOver3                   ; Jump if it's greater than the corresponding digit of the high
                                                                           ; score.
                                  INC HL                                   ; Point HL at the next digit of the high score.
                                  INC DE                                   ; Point DE at the next digit of the current score.
                                  DJNZ DisplayGameOver2                    ; Jump back to compare the next pair of digits.
DisplayGameOver3                  LD HL,Score2+3                           ; Replace the high score with the current score.
                                  LD DE,HighScore
                                  LD BC,6
                                  LDIR

; Now prepare the screen for the game over sequence.

DisplayGameOver4                  LD HL,16384                              ; Clear the top two-thirds of the display file.
                                  LD DE,16385
                                  LD BC,4095
                                  LD (HL),0
                                  LDIR
                                  XOR A                                    ; Initialise the game status buffer variable at
                                                                           ; MultiUseCoordinateStore
                                  LD (MultiUseCoordinateStore),A           ; This variable will determine the distance of the boot from the
                                                                           ; top of the screen.
                                  LD DE,WillySpriteData1                   ; Draw Willy at (12,15).
                                  LD HL,18575
                                  LD C,0
                                  CALL DrawASprite
                                  LD DE,PlinthGraphicData                  ; Draw the plinth (In TheColdRoomData) underneath Willy at
                                  LD HL,18639                              ; (14,15).
                                  LD C,0
                                  CALL DrawASprite

; The following loop draws the boot's descent onto the plinth that supports Willy.

DisplayGameOver5                  LD A,(MultiUseCoordinateStore)           ; Pick up the distance variable from MultiUseCoordinateStore.
                                  LD C,A                                   ; Point BC at the corresponding entry in the screen buffer
                                  LD B,high YTable                         ; address lookup table.
                                  LD A,(BC)                                ; Point HL at the corresponding location in the display file
                                  OR 15
                                  LD L,A
                                  INC BC
                                  LD A,(BC)
                                  SUB 32
                                  LD H,A
                                  LD DE,47840                              ; Draw the boot (see 47840) at this location, without erasing
                                  LD C,0                                   ; the boot at the previous location; this leaves the portion
                                  CALL DrawASprite                         ; of the boot sprite that's above the ankle in place,and makes
                                                                           ; the boot appear as if it's at the end of a long, extending
                                                                           ; trouser leg.
                                  LD A,(MultiUseCoordinateStore)           ; Pick up the distance variable from MultiUseCoordinateStore
                                  CPL                                      ; A=255-A
                                  LD E,A                                   ; Store this value (63-255) in E; it determines the (rising)
                                                                           ; pitch of the sound effect that will be made.
                                  XOR A                                    ; A=0 (black border).
                                  LD BC,64                                 ; C=64; this value determines the duration of the sound effect
DisplayGameOver6                  OUT (254),A                              ; Produce a short note whose pitch is determined by E.
                                  XOR 24
                                  LD B,E
                                  DJNZ .
                                  DEC C
                                  JR NZ,DisplayGameOver6
                                  LD HL,22528                              ; Prepare BC, DE and HL for setting the attribute bytes in the
                                  LD DE,22529                              ; top two-thirds of the screen.
                                  LD BC,511
                                  LD A,(MultiUseCoordinateStore)           ; Pick up the distance variable from MultiUseCoordinateStore
                                  AND 12                                   ; Keep only bits 2 and 3
                                  RLCA                                     ; Shift bits 2 and 3 into bits 3 and 4; these bits determine the
                                                                           ; PAPER colour: 0, 1, 2 or 3.
                                  OR 71                                    ; Set bits 0-2 (INK 7) and 6 (BRIGHT 1).
                                  LD (HL),A                                ; Copy this attribute value into the top two-thirds of the
                                  LDIR                                     ; screen.
                                  LD A,(MultiUseCoordinateStore)           ; Add 4 to the distance variable at MultiUseCoordinateStore;
                                  ADD A,4                                  ; this will move the boot sprite down two pixel rows.
                                  LD (MultiUseCoordinateStore),A
                                  CP 196                                   ; Has the boot met the plinth yet?
                                  JR NZ,DisplayGameOver5                   ; Jump back if not.

; Now print the "Game Over" message, just to drive the point home.

                                  LD IX,GameText                           ; Print "Game" at (6,10).
                                  LD C,4
                                  LD DE,16586
                                  CALL PrintAMessage
                                  LD IX,OverText                           ; Print "Over" at (6,18).
                                  LD C,4
                                  LD DE,16594
                                  CALL PrintAMessage
                                  LD BC,0                                  ; Prepare the delay counters for the following loop; the counter
                                  LD D,6                                   ; in C will also determine the INK colours to use for the
                                                                           ; "Game Over" message.

; The following loop makes the "Game Over" message glisten for about 1.57s.

DisplayGameOver7                  DJNZ DisplayGameOver7                    ; Delay for about a millisecond.
                                  LD A,C                                   ; Change the INK colour of the "G" in "Game" at (6,10).
                                  AND 7
                                  OR 64
                                  LD (22730),A
                                  INC A                                    ; Change the INK colour of the "a" in "Game" at (6,11).
                                  AND 7
                                  OR 64
                                  LD (22731),A
                                  INC A                                    ; Change the INK colour of the "m" in "Game" at (6,12).
                                  AND 7
                                  OR 64
                                  LD (22732),A
                                  INC A                                    ; Change the INK colour of the "e" in "Game" at (6,13).
                                  AND 7
                                  OR 64
                                  LD (22733),A
                                  INC A                                    ; Change the INK colour of the "O" in "Over" at (6,18).
                                  AND 7
                                  OR 64
                                  LD (22738),A
                                  INC A                                    ; Change the INK colour of the "v" in "Over" at (6,19).
                                  AND 7
                                  OR 64
                                  LD (22739),A
                                  INC A                                    ; Change the INK colour of the "e" in "Over" at (6,20).
                                  AND 7
                                  OR 64
                                  LD (22740),A
                                  INC A                                    ; Change the INK colour of the "r" in "Over" at (6,21).
                                  AND 7
                                  OR 64
                                  LD (22741),A
                                  DEC C                                    ; Decrement the counter in C.
                                  JR NZ,DisplayGameOver7                   ; Jump back unless it's zero.
                                  DEC D                                    ; Decrement the counter in D (initially 6).
                                  JR NZ,DisplayGameOver7                   ; Jump back unless it's zero.
                                  JP Start                                 ; Display the title screen and play the theme tune.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Decrease the air remaining in the current cavern               ;
;                                                                ;
; Returns with the zero flag set if there is no air remaining.   ;
;                                                                ;
; ---------------------------------------------------------------;

DecreaseAirRemaining              LD A,(GameClock)                         ; Update the game clock.
                                  SUB 4
                                  LD (GameClock),A
                                  CP 252                                   ; Was it just decreased from zero?
                                  JR NZ,DecreaseAirRemaining2              ; Jump if not.
                                  LD A,(RemainingAirSupply)                ; Pick up the value of the remaining air supply
                                  CP 36                                    ; Has the air supply run out?
                                  RET Z                                    ; Return (with the zero flag set) if so.
                                  DEC A                                    ; Decrement the air supply.
                                  LD (RemainingAirSupply),A
                                  LD A,(GameClock)                         ; Pick up the value of the game clock.
DecreaseAirRemaining2             AND 224                                  ; A = INT(A / 32).
                                  RLCA                                     ; this value specifies how many pixels to draw from left to.
                                  RLCA                                     ; right in the cell at the right end of the air bar
                                  RLCA
                                  LD E,0                                   ; Initialise E to 0 (all bits reset).
                                  OR A                                     ; Do we need to draw any pixels in the cell at the right end of
                                                                           ; the air bar?
                                  JR Z,DecreaseAirRemaining4               ; Jump if not.
                                  LD B,A                                   ; Copy the number of pixels to draw (1-7) to B.
DecreaseAirRemaining3             RRC E                                    ; Set this many bits in E (from bit 7 towards bit 0).
                                  SET 7,E
                                  DJNZ DecreaseAirRemaining3
DecreaseAirRemaining4             LD A,(RemainingAirSupply)                ; Pick up the value of the remaining air supply.
                                  LD L,A                                   ; Set HL to the display file address at which to draw the top
                                  LD H,82                                  ; row of pixels in the cell at the right end of the air bar.
                                  LD B,4                                   ; There are four rows of pixels to draw
DecreaseAirRemaining5             LD (HL),E                                ; Draw the four rows of pixels at the right end of the air bar
                                  INC H
                                  DJNZ DecreaseAirRemaining5
                                  XOR A                                    ; Reset the zero flag to indicate that there is still some air
                                  INC A                                    ; remaining these instructions are redundant, since the zero
                                                                           ; flag is already reset at this point.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Draw the current cavern to the screen buffer                   ;
;                                                                ;
; ---------------------------------------------------------------;

DrawCurrentCavernToScreenBuffer   LD IX,EmptyCavernAttributeBuffer         ; Point IX at the first byte of the attribute buffer at
                                                                           ; EmptyCavernAttributeBuffer.
                                  LD A,high EmptyCavernScreenBuffer        ; Set the operand of the 'LD D,n' instruction
                                                                           ; DrawCurrentCavernToScreenBuffer4 + 1 (below).
                                  LD (DrawCurrentCavernToScreenBuffer4+1),A
                                  CALL DrawCurrentCavernToScreenBuffer2    ; Draw the tiles for the top half of the cavern to the screen
                                                                           ; buffer at EmptyCavernScreenBuffer

                                  LD IX,EmptyCavernAttributeBuffer + 256   ; Point IX at the 256th byte of the attribute buffer at
                                                                           ; EmptyCavernAttributeBuffer in preparation for drawing the
                                                                           ; bottom half of the cavern; this instruction is redundant, since
                                                                           ; IX already holds 24320.
                                  LD A,high EmptyCavernScreenBuffer + $800 ; Set the operand of the 'LD D,n' instruction at (35483)
                                                                           ; DrawCurrentCavernToScreenBuffer4 + 1 (below)
                                  LD (DrawCurrentCavernToScreenBuffer4+1),A
DrawCurrentCavernToScreenBuffer2  LD C,0                                   ; C will count 256 tiles

; The following loop draws 256 tiles (for either the top half or the bottom half of the cavern) to the screen buffer at
; EmptyCavernScreenBuffer.

DrawCurrentCavernToScreenBuffer3  LD E,C                                   ; E holds the LSB of the screen buffer address
                                  LD A,(IX+0)                              ; Pick up an attribute byte from the buffer at
                                                                           ; EmptyCavernAttributeBuffer; this identifies the type of tile
                                                                           ; to draw.
                                  LD HL,BackgroundTile                     ; Move HL through the attribute bytes and graphic data of the
                                                                           ; background, floor, crumbling floor, wall, conveyor and nasty
                                                                           ; tiles starting at CavernTiles until we find a byte that matches
                                                                           ; the attribute byte of the tile to be drawn.
                                  LD BC,72
                                  CPIR
                                  LD C,E                                   ; Restore the value of the tile counter in C
                                  LD B,8                                   ; There are eight bytes in the tile
DrawCurrentCavernToScreenBuffer4  LD D,0                                   ; This instruction is set to the high byte of an address in the
                                                                           ; buffer; now DE holds the address in the screen buffer at
                                                                           ; EmptyCavernScreenBuffer.
DrawCurrentCavernToScreenBuffer5  LD A,(HL)                                ; Copy the tile graphic data to the screen buffer at
                                  LD (DE),A                                ; EmptyCavernScreenBuffer.
                                  INC HL
                                  INC D
                                  DJNZ DrawCurrentCavernToScreenBuffer5
                                  INC IX                                   ; Move IX along to the next byte in the attribute buffer
                                  INC C                                    ; Have we drawn 256 tiles yet?
                                  JP NZ,DrawCurrentCavernToScreenBuffer3   ; If not, jump back to draw the next one.

; The empty cavern has been drawn to the screen buffer at EmptyCavernScreenBuffer. If we're in The Final Barrier, however, there is further
; work to do.

                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern from
                                                                           ; CurrentCavernNumber.
                                  CP 19                                    ; Is it The Final Barrier?
                                  RET NZ                                   ; Return if not
                                  LD HL,TitleScreenDataTop                 ; Copy the graphic data from TitleScreenDataTop to the top half
                                  LD DE,EmptyCavernScreenBuffer            ; of the screen buffer at EmptyCavernScreenBuffer.
                                  LD BC,2048
                                  LDIR
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move Willy (1)                                                 ;
;                                                                ;
; This routine deals with Willy if he's jumping or falling.      ;
;                                                                ;
; ---------------------------------------------------------------;

MoveWilly1                        LD A,(AirborneStatusIndicator)           ; Pick up the airborne status indicator from.
                                  CP 1                                     ; Is Willy jumping?
                                  JR NZ,MW1x4                              ; Jump if not.

; Willy is currently jumping.

                                  LD A,(JumpingAnimationCounter)           ; Pick up the jumping animation counter (0-17).
                                  RES 0,A                                  ; Now -8 <= A <= 8 (and A is even).
                                  SUB 8
                                  LD HL,WillysPixelYCoord                  ; Adjust Willy's pixel y-coordinate at WillysPixelYCoord.
                                  ADD A,(HL)                               ; depending on where Willy is in the jump.
                                  LD (HL),A
                                  CALL MW1x8                               ; Adjust Willy's attribute buffer location at
                                                                           ; WillysLocInAttrBuffer depending on his pixel y-coordinate.
                                  LD A,(WallTile)                          ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                  CP (HL)                                  ; Is the top-left cell of Willy's sprite overlapping a wall tile?
                                  JP Z,MW1x11                              ; Jump if so.
                                  INC HL                                   ; Point HL at the top-right cell occupied by Willy's sprite.
                                  CP (HL)                                  ; Is the top-right cell of Willy's sprite overlapping a wall
                                                                           ; tile?
                                  JP Z,MW1x11                              ; Jump if so.
                                  LD A,(JumpingAnimationCounter)           ; Increment the jumping animation counter at 32878
                                  INC A
                                  LD (JumpingAnimationCounter),A
                                  SUB 8                                    ; A = J - 8, where J (1-18) is the new value of the jumping
                                                                           ; animation counter.
                                  JP P,MW1x1                               ; Jump if J >= 8.
                                  NEG                                      ; A = 8 - J (1 <= J <= 7, 1 <= A <=7 ).
MW1x1                             INC A                                    ; A = 1 + ABS(J - 8).
                                  RLCA                                     ; D=8*(1+ABS(J-8)); this value determines the pitch of the
                                  RLCA                                     ; jumping sound effect.
                                  RLCA                                     ;  (rising as Willy rises, falling as Willy falls).
                                  LD D,A
                                  LD C,32                                  ; This value determines the duration of the jumping sound effect.
                                  LD A,(BorderColor)                       ; Pick up the border colour for the current cavern.
MW1x2                             OUT (254),A                              ; Make a jumping sound effect.
                                  XOR 24
                                  LD B,D
                                  DJNZ .
                                  DEC C
                                  JR NZ,MW1x2
                                  LD A,(JumpingAnimationCounter)           ; Pick up the jumping animation counter (1-18)
                                  CP 18                                    ; Has Willy reached the end of the jump?
                                  JP Z,MW1x9                               ; Jump if so.
                                  CP 16                                    ; Is the jumping animation counter now 16?
                                  JR Z,MW1x4                               ; Jump if so.
                                  CP 13                                    ; Is the jumping animation counter now 13?
                                  JP NZ,MV2x7                              ; Jump if not.

; If we get here, then Willy is standing on the floor, or he's falling, or his jumping animation counter is 13 (at which point Willy is on
; his way down and is exactly two cell-heights above where he started the jump) or 16 (at which point Willy is on his way down and is
; exactly one cell-height above where he started the jump).

MW1x4                             LD A,(WillysPixelYCoord)                 ; Pick up Willy's pixel y-coordinate.
                                  AND 15                                   ; Does Willy's sprite occupy six cells at the moment?
                                  JR NZ,MW1x5                              ; Jump if so.
                                  LD HL,(WillysLocInAttrBuffer)            ; Pick up Willy's attribute buffer coordinates.
                                  LD DE,64                                 ; Point HL at the left-hand cell below Willy's sprite.
                                  ADD HL,DE
                                  LD A,(CrumblingFloorTile)                ; Pick up the attribute byte of the crumbling floor tile for
                                                                           ; the current cavern.
                                  CP (HL)                                  ; Does the left-hand cell below Willy's sprite contain a
                                                                           ; crumbling floor tile?
                                  CALL Z,AnimateCrumblingFloor             ; If so, make it crumble.
                                  LD A,(NastyTile1)                        ; Pick up the attribute byte of the first nasty tile for the
                                                                           ; current cavern.
                                  CP (HL)                                  ; Does the left-hand cell below Willy's sprite contain
                                                                           ; a nasty tile?
                                  JR Z,MW1x5                               ; Jump if so.
                                  LD A,(NastyTile2)                        ; Pick up the attribute byte of the second nasty tile for the
                                                                           ; current cavern.
                                  CP (HL)                                  ; Does the left-hand cell below Willy's sprite contain
                                                                           ; a nasty tile?
                                  JR Z,MW1x5                               ; Jump if so.
                                  INC HL                                   ; Point HL at the right-hand cell below Willy's sprite.
                                  LD A,(CrumblingFloorTile)                ; Pick up the attribute byte of the crumbling floor tile for
                                                                           ; the current cavern.
                                  CP (HL)                                  ; Does the right-hand cell below Willy's sprite contain a
                                                                           ; crumbling floor tile?
                                  CALL Z,AnimateCrumblingFloor             ; If so, make it crumble.
                                  LD A,(NastyTile1)                        ; Pick up the attribute byte of the first nasty tile for the
                                                                           ; current cavern.
                                  CP (HL)                                  ; Does the right-hand cell below Willy's sprite contain
                                                                           ; a nasty tile?
                                  JR Z,MW1x5                               ; Jump if so.
                                  LD A,(NastyTile2)                        ; Pick up the attribute byte of the second nasty tile for
                                                                           ; the current cavern.
                                  CP (HL)                                  ; Does the right-hand cell below Willy's sprite contain
                                                                           ; a nasty tile?
                                  JR Z,MW1x5                               ; Jump if so.
                                  LD A,(BackgroundTile)                    ; Pick up the attribute byte of the background tile for
                                                                           ; the current cavern.
                                  CP (HL)                                  ; Set the zero flag if the right-hand cell below Willy's sprite
                                                                           ; is empty.
                                  DEC HL                                   ; Point HL at the left-hand cell below Willy's sprite.
                                  JP NZ,MoveWilly2                         ; Jump if the right-hand cell below Willy's sprite is not empty.
                                  CP (HL)                                  ; Is the left-hand cell below Willy's sprite empty?
                                  JP NZ,MoveWilly2                         ; Jump if not.
MW1x5                             LD A,(AirborneStatusIndicator)           ; Pick up the airborne status indicator.
                                  CP 1                                     ; Is Willy jumping?
                                  JP Z,MV2x7                               ; Jump if so.

; If we get here, then Willy is either in the process of falling or just about to start falling.

                                  LD HL,WillysDirAndMovFlags               ; Reset bit 1 in WillysDirAndMovFlags: Willy is not moving
                                  RES 1,(HL)                               ; left or right.
                                  OR A                                     ; Is Willy already falling?
                                  JP Z,MW1x10                              ; Jump if not.
                                  INC A                                    ; Increment the airborne status indicator.
                                  LD (AirborneStatusIndicator),A
                                  RLCA                                     ; D = 16 * A; this value determines the pitch of the falling
                                  RLCA                                     ; sound effect.
                                  RLCA
                                  RLCA
                                  LD D,A
                                  LD C,32                                  ; This value determines the duration of the falling sound effect.
                                  LD A,(BorderColor)                       ; Pick up the border colour for the current cavern.
MW1x6                             OUT (254),A                              ; Make a falling sound effect.
                                  XOR 24
                                  LD B,D
MW1x7                             DJNZ MW1x7
                                  DEC C
                                  JR NZ,MW1x6
                                  LD A,(WillysPixelYCoord)                 ; Add 8 to Willy's pixel y-coordinate; this moves Willy downwards
                                  ADD A,8                                  ; by 4 pixels.
                                  LD (WillysPixelYCoord),A
MW1x8                             AND $F0                                  ; L=16*Y, where Y is Willy's screen y-coordinate (0-14)
                                  LD L,A
                                  XOR A                                    ; Clear A and the carry flag
                                  RL L                                     ; Now L=32*(Y-8*INT(Y/8)), and the carry flag is set if Willy is
                                                                           ; in the lower half of the cavern (Y >= 8).
                                  ADC A,92                                 ; H = 92 or 93 (MSB of the address of Willy's location in the
                                  LD H,A                                   ; attribute buffer).
                                  LD A,(WillysLocInAttrBuffer)             ; Pick up Willy's screen x-coordinate (1-29) from bits 0-4 in
                                  AND $1F                                  ; WillysLocInAttrBuffer
                                  OR L                                     ; Now L holds the LSB of Willy's attribute buffer address
                                  LD L,A
                                  LD (WillysLocInAttrBuffer),HL            ; Store Willy's updated attribute buffer.
                                  RET

; Willy has just finished a jump.

MW1x9                             LD A,6                                   ; Set the airborne status indicator at to 6.
                                  LD (AirborneStatusIndicator),A           ; Willy will continue to fall unless he's landed on a wall or
                                  RET                                      ; floor block.

; Willy has just started falling.

MW1x10                            LD A,2                                   ; Set the airborne status indicator at to 2.
                                  LD (AirborneStatusIndicator),A
                                  RET

; The top-left or top-right cell of Willy's sprite is overlapping a wall tile.

MW1x11                            LD A,(WillysPixelYCoord)                 ; Adjust Willy's pixel y-coordinate so that the top row of cells
                                                                           ; of his sprite is just below the wall tile.
                                  ADD A,16
                                  AND 240
                                  LD (WillysPixelYCoord),A
                                  CALL MW1x8                               ; Adjust Willy's attribute buffer location to account for this.
                                                                           ; new pixel y-coordinate.
                                  LD A,2                                   ; Set the airborne status indicator to 2: Willy has started
                                  LD (AirborneStatusIndicator),A           ; falling.
                                  LD HL,WillysDirAndMovFlags               ; Reset bit 1 in WillysDirAndMovFlags: Willy is not moving left
                                  RES 1,(HL)                               ; or right.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Animate a crumbling floor tile in the current cavern           ;
;                                                                ;
; HL = Address of the crumbling floor tile's location in the     ;
;      attribute buffer at 23552                                 ;
;                                                                ;
; ---------------------------------------------------------------;

AnimateCrumblingFloor             LD C,L                                  ; Point BC at the bottom row of pixels of the crumbling floor
                                  LD A,H                                  ; tile in the screen buffer at 28672.
                                  ADD A,27
                                  OR 7
                                  LD B,A
AnimateCrumblingFloor2            DEC B                                   ; Collect the pixels from the row above in A.
                                  LD A,(BC)
                                  INC B                                   ; Copy these pixels into the row below it
                                  LD (BC),A
                                  DEC B                                   ; Point BC at the next row of pixels up.
                                  LD A,B                                  ; Have we dealt with the bottom seven pixel rows of the
                                  AND 7                                   ; crumbling floor tile yet?
                                  JR NZ,AnimateCrumblingFloor2            ; If not, jump back to deal with the next one up
                                  XOR A                                   ; Clear the top row of pixels in the crumbling floor tile.
                                  LD (BC),A
                                  LD A,B                                  ; Point BC at the bottom row of pixels in the crumbling floor tile
                                  ADD A,7
                                  LD B,A
                                  LD A,(BC)                               ; Pick up the bottom row of pixels in A.
                                  OR A                                    ; Is the bottom row clear?
                                  RET NZ                                  ; Return if not.

; The bottom row of pixels in the crumbling floor tile is clear. Time to put a background tile in its place.

                                  LD A,(BackgroundTile)                   ; Pick up the attribute byte of the background tile for the
                                                                          ; current cavern.
                                  INC H                                   ; Set HL to the address of the crumbling floor tile's location
                                                                          ; in the attribute buffer at 24064.
                                  INC H
                                  LD (HL),A                               ; Set the attribute at this location to that of the background
                                                                          ; tile.
                                  DEC H                                   ; Set HL back to the address of the crumbling floor tile's
                                  DEC H                                   ; location in the attribute buffer at 23552.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move Willy (2)                                                 ;
;                                                                ;
; This routine checks the keyboard and joystick, and moves       ;
; Willy left or right if necessary.                              ;
;                                                                ;
; Input = HL Attribute buffer address of the left-hand cell      ;
;         below Willy's sprite                                   ;
; ---------------------------------------------------------------;

MoveWilly2                        LD A,(32875)                             ; Pick up the airborne status indicator.
                                  CP 12                                    ; Has Willy just landed after falling from too great a height?
                                  JP NC,KillWilly1                         ; If so, kill him.
                                  LD E,$FF                                 ; Initialise E to $FF (all bits set); it will be used to hold.
                                                                           ; keyboard and joystick readings.
                                  XOR A                                    ; Reset the airborne status indicator (Willy has landed safely).
                                  LD (AirborneStatusIndicator),A
                                  LD A,(ConveyorTile)                      ; Pick up the attribute byte of the conveyor tile for the current
                                                                           ; cavern.
                                  CP (HL)                                  ; Does the attribute byte of the left-hand cell below Willy's
                                                                           ; sprite match that of the conveyor tile?
                                  JR Z,MV2x1                               ; Jump if so.
                                  INC HL                                   ; Point HL at the right-hand cell below Willy's sprite.
                                  CP (HL)                                  ; Does the attribute byte of the right-hand cell below Willy's
                                                                           ; sprite match that of the conveyor tile?
                                  JR NZ,MV2x2                              ; Jump if not.
MV2x1                             LD A,(ConveyorDirection)                 ; Pick up the direction byte of the conveyor definition.
                                                                           ; (0=left, 1=right).
                                  SUB 3                                    ; Now E=253 (bit 1 reset) if the conveyor is moving left, or 254
                                                                           ; (bit 0 reset) if it's moving right.
                                  LD E,A
MV2x2                             LD BC,zeuskeyaddr("POIUY")               ; Read keys P-O-I-U-Y (right, left, right, left, right) into
                                                                           ; bits 0-4 of A.          .
                                  IN A,(C)
                                  AND $1F                                  ; Set bit 5 and reset bits 6 and 7.
                                  OR 32
                                  AND E                                    ; Reset bit 0 if the conveyor is moving right, or bit 1 if it's
                                                                           ; moving left.
                                  LD E,A                                   ; Save the result in E.
                                  LD BC,zeuskeyaddr("QWERT")               ; Read keys Q-W-E-R-T (left, right, left, right, left) into
                                                                           ; bits 0-4 of A.
                                  IN A,(C)
                                  AND $1F                                  ; Keep only bits 0-4, shift them into bits 1-5, and set bit 0.
                                  RLC A
                                  OR 1
                                  AND E                                    ; Merge this keyboard reading into bits 1-5 of E.
                                  LD E,A
                                  LD B,high zeuskeyaddr("12345")           ; Read keys 1-2-3-4-5 ('5' is left) into bits 0-4 of A.
                                  IN A,(C)
                                  RRCA                                     ; Rotate the result right and set bits 0-2 and 4-7; this ignores
                                                                           ; every key except '5' (left).
                                  OR $F7
                                  AND E                                    ; Merge this reading of the '5' key into bit 3 of E.
                                  LD E,A
                                  LD B,high zeuskeyaddr("09876")           ; Read keys 0-9-8-7-6 ('8' is right) into bits 0-4 of A.
                                  IN A,(C)
                                  OR $FB                                   ; Set bits 0, 1 and 3-7; this ignores every key except '8'
                                                                           ; (right).
                                  AND E                                    ; Merge this reading of the '8' key into bit 2 of E.
                                  LD E,A
                                  LD A,(KempJoystickIndicator)             ; Collect the Kempston joystick indicator.
                                  OR A                                     ; Is the joystick connected?
                                  JR Z,MV2x3                               ; Jump if not.
                                  LD BC,31                                 ; Collect input from the joystick.
                                  IN A,(C)
                                  AND 3                                    ; Keep only bits 0 (right) and 1 (left) and flip them.
                                  CPL
                                  AND E                                    ; Merge this reading of the joystick right and left buttons
                                  LD E,A                                   ; into bits 0 and 1 of E.

; At this point, bits 0-5 in E indicate the direction in which Willy is being moved or trying to move.
; If bit 0, 2 or 4 is reset, Willy is being moved or trying to move right; if bit 1, 3 or 5 is reset,
; Willy is being moved or trying to move left.

MV2x3                             LD C,0                                   ; Initialise C to 0 (no movement).
                                  LD A,E                                   ; Copy the movement bits into A.
                                  AND 42                                   ; Keep only bits 1, 3 and 5 (the 'left' bits).
                                  CP 42                                    ; Are any of these bits reset?
                                  JR Z,MV2x4                               ; Jump if not.
                                  LD C,4                                   ; Set bit 2 of C: Willy is moving left.
MV2x4                             LD A,E                                   ; Copy the movement bits into A.
                                  AND 21                                   ; Keep only bits 0, 2 and 4 (the 'right' bits).
                                  CP 21                                    ; Are any of these bits reset?
                                  JR Z,MV2x5                               ; Jump if not.
                                  SET 3,C                                  ; Set bit 3 of C: Willy is moving right.
MV2x5                             LD A,(WillysDirAndMovFlags)              ; Pick up Willy's direction and movement flags
                                  ADD A,C                                  ; Point HL at the entry in the left-right movement table that
                                  LD C,A                                   ; corresponds to the direction Willy is facing, and the direction
                                  LD B,0                                   ; in which he is being moved or trying to move.
                                  LD HL,WillyNotMoving0
                                  ADD HL,BC
                                  LD A,(HL)                                ; Update Willy's direction and movement flags.
                                  LD (WillysDirAndMovFlags),A              ; with the entry from the left-right movement table.

; That is left-right movement taken care of. Now check the jump keys.

                                  LD BC,zeuskeyaddr("[SHIFT]ZXCVBNM[SYM][SPACE]") ; Read keys SHIFT-Z-X-C-V and B-N-M-SS-SPACE.
                                  IN A,(C)
                                  AND $1F                                  ; Are any of these keys being pressed?
                                  CP $1F
                                  JR NZ,MV2x6                              ; Jump if so.
                                  LD B,high zeuskeyaddr("09876")           ; Read keys 0-9-8-7-6 into bits 0-4 of A.
                                  IN A,(C)
                                  AND 9                                    ; Keep only bits 0 (the '0' key) and 3 (the '7' key).
                                  CP 9                                     ; Is '0' or '7' being pressed?
                                  JR NZ,MV2x6                              ; Jump if so.
                                  LD A,(KempJoystickIndicator)             ; Collect the Kempston joystick indicator.
                                  OR A                                     ; Is the joystick connected?
                                  JR Z,MV2x7                               ; Jump if not.
                                  LD BC,31                                 ; Collect input from the joystick.
                                  IN A,(C)
                                  BIT 4,A                                  ; Is the fire button being pressed?
                                  JR Z,MV2x7                               ; Jump if not.

; A jump key or the fire button is being pressed. Time to make Willy jump.

MV2x6                             XOR A                                    ; Initialise the jumping animation counter.
                                  LD (JumpingAnimationCounter),A
                                  INC A                                    ; Set the airborne status indicator to 1: Willy is
                                  LD (AirborneStatusIndicator),A           ; jumping.
MV2x7                             LD A,(WillysDirAndMovFlags)              ; Pick up Willy's direction and movement flags.
                                  AND 2                                    ; Is Willy moving?
                                  RET Z                                    ; Return if not.
                                  LD A,(WillysDirAndMovFlags)              ; Pick up Willy's direction and movement flags.
                                  AND 1                                    ; Is Willy facing right?
                                  JP Z,MV2x10                              ; Jump if so.

; Willy is moving left.

                                  LD A,(WillysAnimationFrame)              ; Pick up Willy's animation frame.
                                  OR A                                     ; Is it 0?
                                  JR Z,MV2x8                               ; If so, jump to move Willy's sprite left across a cell boundary.
                                  DEC A                                    ; Decrement Willy's animation frame.
                                  LD (WillysAnimationFrame),A

                                  RET

; Willy's sprite is moving left across a cell boundary. In the comments that follow,
; (x,y) refers to the coordinates of the top-left cell currently occupied by Willy's sprite.

MV2x8                             LD HL,(WillysLocInAttrBuffer)            ; Collect Willy's attribute buffer coordinates.
                                  DEC HL                                   ; Point HL at the cell at (x-1,y+1).
                                  LD DE,32
                                  ADD HL,DE
                                  LD A,(WallTile)                          ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                  CP (HL)                                  ; Is there a wall tile in the cell pointed to by HL?
                                  RET Z                                    ; Return if so without moving Willy (his path is blocked).
                                  LD A,(WillysPixelYCoord)                 ; Pick up Willy's pixel y-coordinate.
                                  AND 15                                   ; Does Willy's sprite currently occupy only two rows of cells?
                                  JR Z,MV2x9                               ; Jump if so.
                                  LD A,(WallTile)                          ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                  ADD HL,DE                                ; Point HL at the cell at (x - 1, y + 2).
                                  CP (HL)                                  ; Is there a wall tile in the cell pointed to by HL?
                                  RET Z                                    ; Return if so without moving Willy (his path is blocked).
                                  OR A                                     ; Clear the carry flag for subtraction.
                                  SBC HL,DE                                ; Point HL at the cell at (x - 1, y + 1)
MV2x9                             LD A,(WallTile)                          ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                  OR A                                     ; Clear the carry flag for subtraction.
                                  SBC HL,DE                                ; Point HL at the cell at (x - 1, y).
                                  CP (HL)                                  ; Is there a wall tile in the cell pointed to by HL?
                                  RET Z                                    ; Return if so without moving Willy (his path is blocked).
                                  LD (WillysLocInAttrBuffer),HL            ; Save Willy's new attribute buffer coordinates (in HL).
                                  LD A,3                                   ; Change Willy's animation frame from 0 to 3.
                                  LD (WillysAnimationFrame),A
                                  RET

; Willy is moving right.

MV2x10                            LD A,(WillysAnimationFrame)              ; Pick up Willy's animation frame.
                                  CP 3                                     ; Is it 3?
                                  JR Z,MV2x11                              ; If so, jump to move Willy's sprite right across a cell
                                                                           ; boundary.
                                  INC A                                    ; Increment Willy's animation frame
                                  LD (WillysAnimationFrame),A
                                  RET

; Willy's sprite is moving right across a cell boundary. In the comments that follow,
; (x,y) refers to the coordinates of the top-left cell currently occupied by Willy's sprite.

MV2x11                           LD HL,(WillysLocInAttrBuffer)             ; Collect Willy's attribute buffer coordinates.
                                 INC HL                                    ; Point HL at the cell at (x + 2, y).
                                 INC HL
                                 LD DE,32                                  ; Prepare DE for addition.
                                 LD A,(WallTile)                           ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                 ADD HL,DE                                 ; Point HL at the cell at (x + 2, y + 1).
                                 CP (HL)                                   ; Is there a wall tile in the cell pointed to by HL?
                                 RET Z                                     ; Return if so without moving Willy (his path is blocked).
                                 LD A,(WillysPixelYCoord)                  ; Pick up Willy's pixel y-coordinate.
                                 AND 15                                    ; Does Willy's sprite currently occupy only two rows of cells?
                                 JR Z,MV2x12                               ; Jump if so.
                                 LD A,(WallTile)                           ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                 ADD HL,DE                                 ; Point HL at the cell at (x + 2, y + 2).
                                 CP (HL)                                   ; Is there a wall tile in the cell pointed to by HL?
                                 RET Z                                     ; Return if so without moving Willy (his path is blocked).
                                 OR A                                      ; Clear the carry flag for subtraction.
                                 SBC HL,DE                                 ; Point HL at the cell at (x + 2, y + 1).
MV2x12                           LD A,(WallTile)                           ; Pick up the attribute byte of the wall tile for the current
                                                                           ; cavern.
                                 OR A                                      ; Clear the carry flag for subtraction.
                                 SBC HL,DE                                 ; Point HL at the cell at (x + 2, y).
                                 CP (HL)                                   ; Is there a wall tile in the cell pointed to by HL?
                                 RET Z                                     ; Return if so without moving Willy (his path is blocked).
                                 DEC HL                                    ; Point HL at the cell at (x + 1, y).
                                 LD (WillysLocInAttrBuffer),HL             ; Save Willy's new attribute buffer coordinates (in HL).
                                 XOR A                                     ; Change Willy's animation frame from 3 to 0.
                                 LD (WillysAnimationFrame),A
                                 RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Kill Willy.                                                    ;
;                                                                ;
; When Willy lands after falling from too great a height.        ;
; When Willy collides with a horizontal guardian.                ;
; When Willy collides with Eugene.                               ;
; When Willy collides with a vertical guardian.                  ;
; When Willy collides with the Kong Beast.                       ;
;                                                                ;
; ---------------------------------------------------------------;

KillWilly                         POP HL                                   ; Drop the return address from the stack.
KillWilly1                        POP HL                                   ; Drop the return address from the stack.

; This entry point is used when a Skylab falls on Willy.

KillWilly2                        LD A,$FF                                 ; Set the airborne status indicator to $FF.
                                  LD (AirborneStatusIndicator),A           ; (meaning Willy has had a fatal accident).
                                  JP MainLoop6                             ; Jump back into the main loop.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move the horizontal guardians in the current cavern            ;
;                                                                ;
; ---------------------------------------------------------------;

MoveHorzGuardians                 LD IY,HorizontalGuardian1                ; Point IY at the first byte of the first horizontal guardian
                                                                           ; definition at HorizontalGuardian1.
                                  LD DE,7                                  ; Prepare DE for addition.
                                                                           ; (there are 7 bytes in a guardian definition).

; The guardian-moving loop begins here.

MHG1                              LD A,(IY+0)                              ; Pick up the first byte of the guardian definition.
                                  CP $FF                                   ; Have we dealt with all the guardians yet?
                                  RET Z                                    ; Return if so.
                                  OR A                                     ; Is this guardian definition blank?
                                  JR Z,MHG7                                ; If so, skip it and consider the next one.
                                  LD A,(GameClock)                         ; Pick up the value of the game clock
                                  AND 4                                    ; Move bit 2.
                                                                           ; which is toggled on each pass through the main loop).
                                  RRCA                                     ; to bit 7 and clear all the other bits.
                                  RRCA
                                  RRCA
                                  AND (IY+0)                               ; Combine this bit with bit 7 of the first byte of the guardian
                                                                           ; definition, which specifies the guardian's animation speed:
                                                                           ; 0=normal, 1=slow.
                                  JR NZ,MHG7                               ; Jump to consider the next guardian if this one is not due to
                                                                           ; be moved on this pass.

; The guardian will be moved on this pass.

                                  LD A,(IY+4)                              ; Pick up the current animation frame (0-7).
                                  CP 3                                     ; Is it 3 (the terminal frame for a guardian moving right)?
                                  JR Z,MHG3                                ; Jump if so to move the guardian right across a cell boundary
                                                                           ; or turn it round.
                                  CP 4                                     ; Is the current animation frame 4 (the terminal frame for a
                                                                           ; guardian moving left)?
                                  JR Z,MHG5                                ; Jump if so to move the guardian left across a cell boundary or
                                                                           ; turn it round.
                                  JR NC,MHG2                               ; Jump if the animation frame is 5, 6 or 7
                                  INC (IY+4)                               ; Increment the animation frame (this guardian is moving right).
                                  JR MHG7                                  ; Jump forward to consider the next guardian.
MHG2                              DEC (IY+4)                               ; Decrement the animation frame (this guardian is moving left).
                                  JR MHG7                                  ; Jump forward to consider the next guardian.
MHG3                              LD A,(IY+1)                              ; Pick up the LSB of the address of the guardian's location in
                                                                           ; the attribute buffer at 23552.
                                  CP (IY+6)                                ; Has the guardian reached the rightmost point in its path?
                                  JR NZ,MHG4                               ; Jump if not.
                                  LD (IY+4),7                              ; Set the animation frame to 7 (turning the guardian round to
                                                                           ; face left).
                                  JR MHG7                                  ; Jump forward to consider the next guardian.
MHG4                              LD (IY+4),0                              ; Set the animation frame to 0 (the initial frame for a guardian
                                                                           ; moving right)
                                  INC (IY+1)                               ; Increment the guardian's x-coordinate (moving it right across
                                                                           ; a cell boundary).
                                  JR MHG7                                  ; Jump forward to consider the next guardian.
MHG5                              LD A,(IY+1)                              ; Pick up the LSB of the address of the guardian's location in
                                                                           ; the attribute buffer at 23552.
                                  CP (IY+5)                                ; Has the guardian reached the leftmost point in its path?
                                  JR NZ,MHG6                               ; Jump if not.
                                  LD (IY+4),0                              ; Set the animation frame to 0 (turning the guardian round to
                                                                           ; face right).
                                  JR MHG7                                  ; Jump forward to consider the next guardian.
MHG6                              LD (IY+4),7                              ; Set the animation frame to 7 (the initial frame for a guardian
                                                                           ; moving left)
                                  DEC (IY+1)                               ; Decrement the guardian's x-coordinate (moving it left across a
                                                                           ; cell boundary)

; The current guardian definition has been dealt with. Time for the next one.

MHG7                              ADD IY,DE                                ; Point IY at the first byte of the next horizontal guardian
                                                                           ; definition.
                                  JR MHG1                                  ; Jump back to deal with the next horizontal guardian

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move and draw the light beam in Solar Power Generator          ;
;                                                                ;
; ---------------------------------------------------------------;

MoveDrawLightBeam                 LD HL,23575                              ; Point HL at the cell at (0,23) in the attribute buffer.
                                  LD DE,32                                 ; Prepare DE for addition (the beam travels vertically
                                                                           ; downwards to start with).

; The beam-drawing loop begins here.

MoveDrawLightBeam2                LD A,(32809)                             ; Pick up the attribute byte of the floor tile for the cavern.
                                  CP (HL)                                  ; Does HL point at a floor tile?
                                  RET Z                                    ; Return if so (the light beam stops here).
                                  LD A,(32827)                             ; Pick up the attribute byte of the wall tile for the cavern.
                                  CP (HL)                                  ; Does HL point at a wall tile?
                                  RET Z                                    ; Return if so (the light beam stops here).
                                  LD A,39                                  ; A=39 (INK 7: PAPER 4).
                                  CP (HL)                                  ; Does HL point at a tile with this attribute value?
                                  JR NZ,MoveDrawLightBeam3                 ; Jump if not (the light beam is not touching Willy).
                                  EXX                                      ; Switch to the shadow registers briefly (to preserve DE and HL).
                                  CALL DecreaseAirRemaining                ; Decrease the air supply by four units.
                                  CALL DecreaseAirRemaining
                                  CALL DecreaseAirRemaining
                                  CALL DecreaseAirRemaining
                                  EXX                                      ; Switch back to the normal registers (restoring DE and HL).
                                  JR MoveDrawLightBeam4                    ; Jump forward to draw the light beam over Willy.
MoveDrawLightBeam3                LD A,(32800)                             ; Pick up the attribute byte of the background tile for the
                                                                           ; cavern.
                                  CP (HL)                                  ; does HL point at a background tile?
                                  JR Z,MoveDrawLightBeam4                  ; Jump if so.
                                                                           ; (the light beam will not be reflected at this point).
                                  LD A,E                                   ; Toggle the value in DE between 32 and -1 (and therefore the
                                  XOR (32 xor -1)                          ; direction of the light beam between vertically downwards and
                                  LD E,A                                   ; horizontally to the left): the light beam has hit a guardian.
                                  LD A,D
                                  CPL
                                  LD D,A
MoveDrawLightBeam4                LD (HL),119                              ; Draw a portion of the light beam with attribute value 119
                                                                           ; (INK 7: PAPER 6: BRIGHT 1).
                                  ADD HL,DE                                ; Point HL at the cell where the next portion of the light beam
                                                                           ; will be drawn.
                                  JR MoveDrawLightBeam2                    ; Jump back to draw the next portion of the light beam.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Draw the horizontal guardians in the current cavern            ;
;                                                                ;
; ---------------------------------------------------------------;

DrawHorzontalGuardians            LD IY,HorizontalGuardian1                ; Point IY at the first byte of the first horizontal guardian
                                                                           ; definition.

; The guardian-drawing loop begins here.

DrawHorzontalGuardians2           LD A,(IY+0)                              ; Pick up the first byte of the guardian definition.
                                  CP $FF                                   ; Have we dealt with all the guardians yet?
                                  RET Z                                    ; Return if so.
                                  OR A                                     ; Is this guardian definition blank?
                                  JR Z,DrawHorzontalGuardians4             ; If so, skip it and consider the next one.
                                  LD DE,31                                 ; Prepare DE for addition.
                                  LD L,(IY+1)                              ; Point HL at the address of the guardian's location in the
                                  LD H,(IY+2)                              ; attribute buffer at 23552.
                                  AND 127                                  ; Reset bit 7 (which specifies the animation speed) of the
                                                                           ; attribute byte, ensuring no FLASH.
                                  LD (HL),A                                ; Set the attribute bytes for the guardian in the buffer
                                  INC HL                                   ; at 23552.
                                  LD (HL),A
                                  ADD HL,DE
                                  LD (HL),A
                                  INC HL
                                  LD (HL),A
                                  LD C,1                                   ; Prepare C for the call to the drawing routine later on.
                                  LD A,(IY+4)                              ; Pick up the animation frame (0-7).
                                  RRCA                                     ; Multiply it by 32.
                                  RRCA
                                  RRCA
                                  LD E,A                                   ; Copy the result to E.
                                  LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  CP 7                                     ; Are we in one of the first seven caverns?
                                  JR C,DrawHorzontalGuardians3             ; Jump if so.
                                  CP 9                                     ; Are we in The Endorian Forest?
                                  JR Z,DrawHorzontalGuardians3             ; Jump if so.
                                  CP 15                                    ; Are we in The Sixteenth Cavern?
                                  JR Z,DrawHorzontalGuardians3             ; Jump if so.
                                  SET 7,E                                  ; Add 128 to E (the horizontal guardians in this cavern use
                                                                           ; frames 4-7 only).
DrawHorzontalGuardians3           LD D,high GuardianGraphicData            ; Point DE at the graphic data for the appropriate guardian
                                                                           ; sprite (at 33024+E).
                                  LD L,(IY+1)                              ; Point HL at the address of the guardian's location in the
                                                                           ; screen buffer at 24576.
                                  LD H,(IY+3)
                                  CALL DrawASprite                         ; Draw the guardian to the screen buffer at 24576.
                                  JP NZ,KillWilly1                         ; Kill Willy if the guardian collided with him.

; The current guardian definition has been dealt with. Time for the next one.

DrawHorzontalGuardians4           LD DE,7                                  ; Point IY at the first byte of the next horizontal guardian
                                  ADD IY,DE                                ; definition.
                                  JR DrawHorzontalGuardians2               ; Jump back to deal with the next horizontal guardian

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move and draw Eugene in Eugene's Lair                          ;
;                                                                ;
; ---------------------------------------------------------------;

; First we move Eugene up or down, or change his direction.

MoveDrawEugene                    LD A,(AttrLastItemDrawn)                 ; Pick up the attribute of the last item drawn.
                                  OR A                                     ; Have all the items been collected?
                                  JR Z,MoveDrawEugene1                     ; Jump if so.
                                  LD A,(EugDirOrKongBeastStatus)           ; Pick up Eugene's direction.
                                  OR A                                     ; Is Eugene moving downwards?
                                  JR Z,MoveDrawEugene1                     ; Jump if so.
                                  LD A,(MultiUseCoordinateStore)           ; Pick up Eugene's pixel y-coordinate.
                                  DEC A                                    ; Decrement it (moving Eugene up).
                                  JR Z,MoveDrawEugene2                     ; Jump if Eugene has reached the top of the cavern.
                                  LD (MultiUseCoordinateStore),A           ; Update Eugene's pixel y-coordinate.
                                  JR MoveDrawEugene3
MoveDrawEugene1                   LD A,(MultiUseCoordinateStore)           ; Pick up Eugene's pixel y-coordinate.
                                  INC A                                    ; Increment it (moving Eugene down).
                                  CP 88                                    ; Has Eugene reached the portal yet?
                                  JR Z,MoveDrawEugene2                     ; Jump if so.
                                  LD (MultiUseCoordinateStore),A           ; Update Eugene's pixel y-coordinate.
                                  JR MoveDrawEugene3
MoveDrawEugene2                   LD A,(EugDirOrKongBeastStatus)           ; Toggle Eugene's direction.
                                  XOR 1
                                  LD (EugDirOrKongBeastStatus),A

; Now that Eugene's movement has been dealt with, it's time to draw him.

MoveDrawEugene3                   LD A,(MultiUseCoordinateStore)           ; Pick up Eugene's pixel y-coordinate.
                                  AND 127                                  ; Point DE at the entry in the screen buffer address lookup
                                  RLCA                                     ; table that corresponds to Eugene's y-coordinate.
                                  LD E,A
                                  LD D,high YTable
                                  LD A,(DE)                                ; Point HL at the address of Eugene's location in the screen
                                  OR 15                                    ; buffer at 24576.
                                  LD L,A
                                  INC DE
                                  LD A,(DE)
                                  LD H,A
                                  LD DE,32992                              ; Draw Eugene to the screen buffer at 24576.
                                  LD C,1
                                  CALL DrawASprite
                                  JP NZ,KillWilly1                         ; Kill Willy if Eugene collided with him.
                                  LD A,(MultiUseCoordinateStore)           ; Pick up Eugene's pixel y-coordinate.
                                  AND 120                                  ; Point HL at the address of Eugene's location in the attribute
                                  RLCA                                     ; buffer at 23552
                                  OR 7
                                  SCF
                                  RL A
                                  LD L,A
                                  LD A,0
                                  ADC A,92
                                  LD H,A
                                  LD A,(AttrLastItemDrawn)                 ; Pick up the attribute of the last item drawn.
                                  OR A                                     ; Set the zero flag if all the items have been collected.
                                  LD A,7                                   ; Assume we will draw Eugene with white INK.
                                  JR NZ,SetAttributeMulti                  ; Jump if there are items remaining to be collected.
                                  LD A,(GameClock)                         ; Pick up the value of the game clock.
                                  RRCA                                     ; Move bits 2-4 into bits 0-2 and clear the other bits; this
                                  RRCA                                     ; value (which decreases by one on each pass through the main
                                  AND 7                                    ; loop) will be Eugene's INK colour.

; This entry point is used by the routines:
;     To set the attributes for a Skylab.
;     To set the attributes for a vertical guardian.
;     To set the attributes for the Kong Beast.

SetAttributeMulti                 LD (HL),A                                ; Save the INK colour in the attribute buffer temporarily.
                                  LD A,(BackgroundTile)                    ; Pick up the attribute byte of the background tile for the
                                                                           ; current cavern.
                                  AND $F8                                  ; Combine its PAPER colour with the chosen INK colour.
                                  OR (HL)
                                  LD (HL),A                                ; Set the attribute byte for the top-left cell of the sprite in
                                                                           ; the attribute buffer at 23552.
                                  LD DE,31                                 ; Prepare DE for addition.
                                  INC HL                                   ; Set the attribute byte for the top-right cell of the sprite in
                                                                           ; the attribute buffer at 23552.
                                  LD (HL),A
                                  ADD HL,DE                                ; Set the attribute byte for the middle-left cell of the sprite
                                                                           ; in the attribute buffer at 23552.
                                  LD (HL),A
                                  INC HL                                   ; Set the attribute byte for the middle-right cell of the sprite
                                                                           ; in the attribute buffer at 23552.
                                  LD (HL),A
                                  ADD HL,DE                                ; Set the attribute byte for the bottom-left cell of the sprite
                                                                           ; in the attribute buffer at 23552.
                                  LD (HL),A
                                  INC HL                                   ; Set the attribute byte for the bottom-right cell of the sprite
                                                                           ; in the attribute buffer at 23552.
                                  LD (HL),A
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move and draw the Skylabs in Skylab Landing Bay                ;
;                                                                ;
; ---------------------------------------------------------------;

MoveDrawSkyLabs                   LD IY,VerticalGuardian1                  ; Point IY at the first byte of the first vertical guardian
                                                                           ; definition.
; The Skylab-moving loop begins here.

MoveDrawSkyLabs2                  LD A,(IY+0)                              ; Pick up the first byte of the guardian definition.
                                  CP $FF                                   ; Have we dealt with all the Skylabs yet?
                                  JP Z,MainLoop5                           ; If so, re-enter the main loop.
                                  LD A,(IY+2)                              ; Pick up the Skylab's pixel y-coordinate.
                                  CP (IY+6)                                ; Has it reached its crash site yet?
                                  JR NC,MoveDrawSkyLabs3                   ; Jump if so.
                                  ADD A,(IY+4)                             ; Increment the Skylab's y-coordinate (moving it downwards)
                                  LD (IY+2),A
                                  JR MoveDrawSkyLabs4

; The Skylab has reached its crash site. Start or continue its disintegration.

MoveDrawSkyLabs3                  INC (IY+1)                               ; Increment the animation frame.
                                  LD A,(IY+1)                              ; Pick up the animation frame.
                                  CP 8                                     ; Has the Skylab completely disintegrated yet?
                                  JR NZ,MoveDrawSkyLabs4                   ; Jump if not.
                                  LD A,(IY+5)                              ; Reset the Skylab's pixel y-coordinate.
                                  LD (IY+2),A
                                  LD A,(IY+3)                              ; Add 8 to the Skylab's x-coordinate
                                  ADD A,8                                  ; (wrapping around at the right side of the screen).
                                  AND $1F
                                  LD (IY+3),A
                                  LD (IY+1),0                              ; Reset the animation frame to 0.

; Now that the Skylab's movement has been dealt with, time to draw it.

MoveDrawSkyLabs4                  LD E,(IY+2)                              ; Pick up the Skylab's pixel y-coordinate in E.
                                  RLC E                                    ; Point DE at the entry in the screen buffer address lookup table
                                  LD D,high YTable                         ; that corresponds to the Skylab's pixel y-coordinate.
                                  LD A,(DE)                                ; Point HL at the address of the Skylab's location in the
                                  ADD A,(IY+3)                             ; screen buffer at 24576.
                                  LD L,A
                                  INC DE
                                  LD A,(DE)
                                  LD H,A
                                  LD A,(IY+1)                              ; Pick up the animation frame (0-7).
                                  RRCA                                     ; Multiply it by 32.
                                  RRCA
                                  RRCA
                                  LD E,A                                   ; Point DE at the graphic data for the corresponding Skylab
                                  LD D,high GuardianGraphicData            ; sprite (at 33024+A).
                                  LD C,1                                   ; Draw the Skylab to the screen buffer at 24576.
                                  CALL DrawASprite
                                  JP NZ,KillWilly2                         ; Kill Willy if the Skylab collided with him.
                                  LD A,(IY+2)                              ; Point HL at the address of the Skylab's location in the
                                  AND 64                                   ; attribute buffer.
                                  RLCA
                                  RLCA
                                  ADD A,92
                                  LD H,A
                                  LD A,(IY+2)
                                  RLCA
                                  RLCA
                                  AND 224
                                  OR (IY+3)
                                  LD L,A
                                  LD A,(IY+0)                              ; Pick up the Skylab's attribute byte.
                                  CALL SetAttributeMulti                   ; Set the attribute bytes for the Skylab.

; The current guardian definition has been dealt with. Time for the next one.

                                  LD DE,7                                  ; Point IY at the first byte of the next vertical guardian
                                                                           ; definition.
                                  ADD IY,DE
                                  JR MoveDrawSkyLabs2                      ; Jump back to deal with the next Skylab.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move and draw the vertical guardians in the current cavern     ;
;                                                                ;
; ---------------------------------------------------------------;

MoveDrawVerticalGuardians         LD IY,32989                             ; Point IY at the first byte of the first vertical guardian
                                                                          ; definition.

; The guardian-moving loop begins here.

MoveDrawVerticalGuardians2        LD A,(IY+0)                             ; Pick up the first byte of the guardian definition.
                                  CP $FF                                  ; Have we dealt with all the guardians yet?
                                  RET Z                                   ; Return if so.
                                  INC (IY+1)                              ; Increment the guardian's animation frame.
                                  RES 2,(IY+1)                            ; Reset the animation frame to 0 if it overflowed to 4.
                                  LD A,(IY+2)                             ; Pick up the guardian's pixel y-coordinate.
                                  ADD A,(IY+4)                            ; Add the current y-coordinate increment.
                                  CP (IY+5)                               ; Has the guardian reached the highest point of its path
                                                                          ; (minimum y-coordinate)?
                                  JR C,MoveDrawVerticalGuardians3         ; If so, jump to change its direction of movement.
                                  CP (IY+6)                               ; Has the guardian reached the lowest point of its path
                                                                          ; (maximum y-coordinate)?
                                  JR NC,MoveDrawVerticalGuardians3        ; If so, jump to change its direction of movement.
                                  LD (IY+2),A                             ; Update the guardian's pixel y-coordinate.
                                  JR MoveDrawVerticalGuardians4

MoveDrawVerticalGuardians3        LD A,(IY+4)                             ; Negate the y-coordinate increment; this changes the guardian's
                                  NEG                                     ; direction of movement.
                                  LD (IY+4),A

; Now that the guardian's movement has been dealt with, time to draw it.

MoveDrawVerticalGuardians4        LD A,(IY+2)                             ; Pick up the guardian's pixel y-coordinate
                                  AND 127                                 ; Point DE at the entry in the screen buffer address lookup table
                                  RLCA                                    ; that corresponds to the guardian's pixel y-coordinate.
                                  LD E,A
                                  LD D,high YTable
                                  LD A,(DE)                               ; Point HL at the address of the guardian's location in the screen
                                  OR (IY+3)                               ; buffer at 24576.
                                  LD L,A
                                  INC DE
                                  LD A,(DE)
                                  LD H,A
                                  LD A,(IY+1)                             ; Pick up the guardian's animation frame (0-3).
                                  RRCA                                    ; Multiply it by 32.
                                  RRCA
                                  RRCA
                                  LD E,A                                  ; Point DE at the graphic data for the appropriate guardian
                                  LD D,high GuardianGraphicData           ; sprite (at GuardianGraphicData+A).
                                  LD C,1                                  ; Draw the guardian to the screen buffer at 24576.
                                  CALL DrawASprite
                                  JP NZ,KillWilly1                        ; Kill Willy if the guardian collided with him.
                                  LD A,(IY+2)                             ; Pick up the guardian's pixel y-coordinate.
                                  AND 64                                  ; Point HL at the address of the guardian's location in the
                                  RLCA                                    ; attribute buffer at 23552.
                                  RLCA
                                  ADD A,92
                                  LD H,A
                                  LD A,(IY+2)
                                  RLCA
                                  RLCA
                                  AND 224
                                  OR (IY+3)
                                  LD L,A
                                  LD A,(IY+0)                             ; Pick up the guardian's attribute byte.
                                  CALL SetAttributeMulti                  ; Set the attribute bytes for the guardian.

; The current guardian definition has been dealt with. Time for the next one.

                                  LD DE,7                                 ; Point IY at the first byte of the next vertical
                                  ADD IY,DE                               ; guardian definition.
                                  JR MoveDrawVerticalGuardians2           ; Jump back to deal with the next vertical guardian.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Draw the items in the current cavern and collect any that      ;
; Willy is touching                                              ;
;                                                                ;
; ---------------------------------------------------------------;

DrawCollectItemsWillyTouching     XOR A                                    ; Initialise the attribute of the last item drawn to 0.
                                  LD (AttrLastItemDrawn),A                 ; (in case there are no items left to draw).
                                  LD IY,ItemDef1                           ; Point IY at the first byte of the first item definition.

; The item-drawing loop begins here.

DrawCollectItemsWillyTouching1    LD A,(IY+0)                              ; Pick up the first byte of the item definition.
                                  CP $FF                                   ; Have we dealt with all the items yet?
                                  JR Z,DrawCollectItemsWillyTouching4      ; Jump if so.
                                  OR A                                     ; Has this item already been collected?
                                  JR Z,DrawCollectItemsWillyTouching3      ; If so, skip it and consider the next one.
                                  LD E,(IY+1)                              ; Point DE at the address of the item's location in the attribute
                                  LD D,(IY+2)                              ; buffer at 23552.
                                  LD A,(DE)                                ; Pick up the current attribute byte at the item's location.
                                  AND 7                                    ; Is the INK white
                                  CP 7                                     ; (which happens if Willy is touching the item)?
                                  JR NZ,DrawCollectItemsWillyTouching2     ; Jump if not.

; Willy is touching this item, so add it to his collection.

                                  LD HL,Score2+6                           ; Add 100 to the score
                                  CALL AddToTheScore1
                                  LD (IY+0),0                              ; Set the item's attribute byte to 0 so that it will be skipped
                                                                           ; the next time.
                                  JR DrawCollectItemsWillyTouching3        ; Jump forward to consider the next item.

; This item has not been collected yet.

DrawCollectItemsWillyTouching2    LD A,(IY+0)                              ; Pick up the item's current attribute byte.
                                  AND 248                                  ; Keep the BRIGHT and PAPER bits, and set the INK to 3 (magenta).
                                  OR 3                                     ;
                                  LD B,A                                   ; Store this value in B.
                                  LD A,(IY+0)                              ; Pick up the item's current attribute byte again.
                                  AND 3                                    ; Keep only bits 0 and 1 and add the value in B; this maintains.
                                  ADD A,B                                  ; the BRIGHT and PAPER bits, and cycles the INK colour through.
                                                                           ; 3, 4, 5 and 6.
                                  LD (IY+0),A                              ; Store the new attribute byte.
                                  LD (DE),A                                ; Update the attribute byte at the item's location in the buffer
                                                                           ; at 23552.
                                  LD (AttrLastItemDrawn),A                 ; Store the new attribute byte at AttrLastItemDrawn as well
                                  LD D,(IY+3)                              ; Point DE at the address of the item's location in the screen
                                                                           ; buffer at 24576.
                                  LD HL,ItemGraphic                        ; Point HL at the item graphic for the current cavern.
                                  LD B,8                                   ; There are eight pixel rows to copy.
                                  CALL DrawItem                            ; Draw the item to the screen buffer at 24576.

; The current item definition has been dealt with. Time for the next one.

DrawCollectItemsWillyTouching3    INC IY                                   ; Point IY at the first byte of the next item definition.
                                  INC IY
                                  INC IY
                                  INC IY
                                  INC IY
                                  JR DrawCollectItemsWillyTouching1        ; Jump back to deal with the next item.

; All the items have been dealt with. Check whether there were any left.

DrawCollectItemsWillyTouching4    LD A,(AttrLastItemDrawn)                 ; Pick up the attribute of the last item drawn.
                                  OR A                                     ; Were any items drawn?
                                  RET NZ                                   ; Return if so (some remain to be collected).
                                  LD HL,PortalDefAttributeByte             ; Ensure that the portal is flashing by setting bit 7 of its
                                  SET 7,(HL)                               ; attribute byte.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Draw the portal.                                               ;
;                                                                ;
; Move to the next cavern if Willy has entered it.               ;
;                                                                ;
; ---------------------------------------------------------------;

; First check whether Willy has entered the portal.

DrawThePortal                     LD HL,(PortalDefAttributeBuf)            ; Pick up the address of the portal's location in the
                                                                           ; attribute buffer at 23552 from PortalDefAttributeBuf.
                                  LD A,(WillysLocInAttrBuffer)             ; Pick up the LSB of the address of Willy's location in the
                                                                           ; attribute buffer at 23552 from WillysLocInAttrBuffer.
                                  CP L                                     ; Does it match that of the portal?
                                  JR NZ,DrawThePortal2                     ; Jump if not.
                                  LD A,(JumpingAnimationCounter - 1)       ; Pick up the MSB of the address of Willy's location in the
                                                                           ; attribute buffer at 23552 from (JumpingAnimationCounter - 1).
                                  CP H                                     ; Does it match that of the portal?
                                  JR NZ,DrawThePortal2                     ; Jump if not.
                                  LD A,(PortalDefAttributeByte)            ; Pick up the portal's attribute byte from
                                                                           ; PortalDefAttributeByte.
                                  BIT 7,A                                  ; Is the portal flashing?
                                  JR Z,DrawThePortal2                      ; Jump if not.
                                  POP HL                                   ; Drop the return address from the stack.
                                  JP MoveToTheNextCavern                   ; Move Willy to the next cavern.

; Willy has not entered the portal, or it's not flashing, so just draw it.

DrawThePortal2                    LD A,(PortalDefAttributeByte)            ; Pick up the portal's attribute byte from
                                                                           ; PortalDefAttributeByte.
                                  LD (HL),A                                ; Set the attribute bytes for the portal in the buffer at
                                                                           ; 23552
                                  INC HL
                                  LD (HL),A
                                  LD DE,31
                                  ADD HL,DE
                                  LD (HL),A
                                  INC HL
                                  LD (HL),A
                                  LD DE,PortalDefGraphicData               ; Point DE at the graphic data for the portal at
                                                                           ; PortalDefGraphicData.
                                  LD HL,(PortalDefScreenBuf)               ; Pick up the address of the portal's location in the screen
                                                                           ; buffer at 24576 from PortalDefScreenBuf.
                                  LD C,0                                   ; C = 0: overwrite mode.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Draw a sprite.                                                 ;
;                                                                ;
; If C=1 on entry, this routine returns with the zero flag       ;
; reset if any of the set bits in the sprite being drawn         ;
; collides with a set bit in the background.                     ;
;                                                                ;
; Input                                                          ;
; ---------------------------------------------                  ;
;  C = Drawing mode: 0 (overwrite) or 1 (blend)                  ;
; DE = Address of sprite graphic data                            ;
; HL = Address to draw at                                        ;
;                                                                ;
; ---------------------------------------------------------------;

DrawASprite                       LD B,16                                  ; There are 16 rows of pixels to draw.
DAS1                              BIT 0,C                                  ; Set the zero flag if we're in overwrite mode.
                                  LD A,(DE)                                ; Pick up a sprite graphic byte.
                                  JR Z,DAS2                                ; Jump if we're in overwrite mode.
                                  AND (HL)                                 ; Return with the zero flag reset if any of the set bits in the
                                  RET NZ                                   ; sprite graphic byte collide with a set bit in the background
                                                                           ; (e.g. in Willy's sprite).
                                  LD A,(DE)                                ; Pick up the sprite graphic byte again.
                                  OR (HL)                                  ; Blend it with the background byte.
DAS2                              LD (HL),A                                ; Copy the graphic byte to its destination cell.
                                  INC L                                    ; Move HL along to the next cell on the right.
                                  INC DE                                   ; Point DE at the next sprite graphic byte.
                                  BIT 0,C                                  ; Set the zero flag if we're in overwrite mode.
                                  LD A,(DE)                                ; Pick up a sprite graphic byte.
                                  JR Z,DAS3                                ; Jump if we're in overwrite mode.
                                  AND (HL)                                 ; Return with the zero flag reset if any of the set bits in the
                                  RET NZ                                   ; sprite graphic byte collide with a set bit in the background
                                                                           ; (e.g. in Willy's sprite).
                                  LD A,(DE)                                ; Pick up the sprite graphic byte again.
                                  OR (HL)                                  ; Blend it with the background byte.
DAS3                              LD (HL),A                                ; Copy the graphic byte to its destination cell.
                                  DEC L                                    ; Move HL to the next pixel row down in the cell on the left.
                                  INC H
                                  INC DE                                   ; Point DE at the next sprite graphic byte.
                                  LD A,H                                   ; Have we drawn the bottom pixel row in this pair of cells yet?
                                  AND 7
                                  JR NZ,DAS4                               ; Jump if not.
                                  LD A,H                                   ; Otherwise move HL to the top pixel row in the cell below.
                                  SUB 8
                                  LD H,A
                                  LD A,L
                                  ADD A,32
                                  LD L,A
                                  AND $E0                                  ; Was the last pair of cells at y-coordinate 7 or 15?
                                  JR NZ,DAS4                               ; Jump if not.
                                  LD A,H                                   ; Otherwise adjust HL to account for the movement from the top or
                                                                           ; middle third of the screen to the next one down.
                                  ADD A,8
                                  LD H,A
DAS4                              DJNZ DAS1                                ; Jump back until all 16 rows of pixels have been drawn.
                                  XOR A                                    ; Set the zero flag (to indicate no collision).
                                  RET


; ---------------------------------------------------------------;
;                                                                ;
; Move to the next cavern                                        ;
;                                                                ;
; ---------------------------------------------------------------;

MoveToTheNextCavern               LD A,(CurrentCavernNumber)               ; Pick up the number of the current cavern.
                                  INC A                                    ; Increment the cavern number.
                                  CP 20                                    ; Is the current cavern The Final Barrier?
                                  JR NZ,MoveToTheNextCavern4               ; Jump if not.
                                  LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Are we in demo mode?.
                                  JP NZ,MoveToTheNextCavern3               ; Jump if so.
                                  LD A,(KeyCounter)                        ; Pick up the 6031769 key counter.
                                  CP 7                                     ; Is cheat mode activated?
                                  JR Z,MoveToTheNextCavern3                ; Jump if so.

; Willy has made it through The Final Barrier without cheating.

                                  LD C,0                                   ; Draw Willy at (2,19) on the ground above the portal.
                                  LD DE,WillySpriteData2
                                  LD HL,16467
                                  CALL DrawASprite
                                  LD DE,SwordfishGraphicData               ; Draw the swordfish graphic over the portal.
                                  LD HL,16563
                                  CALL DrawASprite
                                  LD HL,22611                              ; Point HL at (2,19) in the attribute file.
                                  LD DE,31                                 ; Prepare DE for addition.
                                  LD (HL),47                               ; Set the attributes for the upper half of Willy's sprite
                                                                           ; at (2,19) and (2,20) to 47 (INK 7: PAPER 5).
                                  INC HL
                                  LD (HL),47
                                  ADD HL,DE                                ; Set the attributes for the lower half of Willy's sprite
                                                                           ; at (3,19) and (3,20) to 39 (INK 7: PAPER 4).
                                  LD (HL),39
                                  INC HL
                                  LD (HL),39
                                  ADD HL,DE                                ; Point HL at (5,19) in the attribute file.
                                  INC HL
                                  ADD HL,DE
                                  LD (HL),69                               ; Set the attributes for the fish at (5,19) and (5,20)
                                                                           ; to 69 (INK 5: PAPER 0: BRIGHT 1).
                                  INC HL
                                  LD (HL),69
                                  ADD HL,DE                                ; Set the attribute for the handle of the sword at (6,19)
                                                                           ; to 70 (INK 6: PAPER 0: BRIGHT 1).
                                  LD (HL),70                               ;
                                  INC HL                                   ; Set the attribute for the blade of the sword at (6,20)
                                                                           ; to 71 (INK 7: PAPER 0: BRIGHT 1).
                                  LD (HL),71
                                  ADD HL,DE                                ; Set the attributes at (7,19) and (7,20) to 0
                                                                           ; (to hide Willy's feet just below where the portal was).
                                  LD (HL),0
                                  INC HL
                                  LD (HL),0
                                  LD BC,0                                  ; Prepare C and D for the celebratory sound effect.
                                  LD D,50
                                  XOR A                                    ; A=0 (black border).
MoveToTheNextCavern1              OUT (254),A                              ; Produce the celebratory sound effect: Willy has escaped
                                                                           ; from the mine.
                                  XOR 24
                                  LD E,A
                                  LD A,C
                                  ADD A,D
                                  ADD A,D
                                  ADD A,D
                                  LD B,A
                                  LD A,E
MoveToTheNextCavern2              DJNZ MoveToTheNextCavern2
                                  DEC C
                                  JR NZ,MoveToTheNextCavern1
                                  DEC D
                                  JR NZ,MoveToTheNextCavern1
MoveToTheNextCavern3              XOR A                                    ; A=0 (the next cavern will be Central Cavern).
MoveToTheNextCavern4              LD (CurrentCavernNumber),A               ; Update the cavern number.

; The next section of code cycles the INK and PAPER colours of the current cavern.

                                  LD A,63                                  ; Initialise A to 63 (INK 7: PAPER 7).
MoveToTheNextCavern5              LD HL,22528                              ; Set the attributes for the top two-thirds of the screen to the
                                                                           ; value in A.
                                  LD DE,22529
                                  LD BC,511
                                  LD (HL),A
                                  LDIR
                                  LD BC,4                                  ; Pause for about 0.004s.
MoveToTheNextCavern6              DJNZ MoveToTheNextCavern6
                                  DEC C
                                  JR NZ,MoveToTheNextCavern6
                                  DEC A                                    ; Decrement the attribute value in A
                                  JR NZ,MoveToTheNextCavern5               ; Jump back until we've gone through all attribute values from
                                                                           ; 63 down to 1.
                                  LD A,(GameModeIndicator)                 ; Pick up the game mode indicator.
                                  OR A                                     ; Are we in demo mode?
                                  JP NZ,Start7                             ; If so, demo the next cavern.

; The following loop increases the score and decreases the air supply until it runs out.

MoveToTheNextCavern7              CALL DecreaseAirRemaining                ; Decrease the air remaining in the current cavern.
                                  JP Z,Start7                              ; Move to the next cavern if the air supply is now gone.
                                  LD HL,Score2+8                           ; Add 1 to the score.
                                  CALL AddToTheScore1
                                  LD IX,Score2+3                           ; Print the new score at (19,26).
                                  LD C,6
                                  LD DE,20602
                                  CALL PrintAMessage
                                  LD C,4                                   ; This value determines the duration of the sound effect.
                                  LD A,(RemainingAirSupply)                ; Pick up the remaining air supply.
                                  CPL                                      ; D=2*(63-S); this value determines the pitch of the sound effect.
                                                                           ; (which decreases with the amount of air remaining).
                                  AND 63
                                  RLC A
                                  LD D,A
MoveToTheNextCavern8              LD A,0                                   ; Produce a short note.
                                  OUT (254),A
                                  LD B,D
MoveToTheNextCavern9              DJNZ MoveToTheNextCavern9
                                  LD A,24
                                  OUT (254),A
                                  LD B,D
MoveToTheNextCavern10             DJNZ MoveToTheNextCavern10
                                  DEC C
                                  JR NZ,MoveToTheNextCavern8
                                  JR MoveToTheNextCavern7                  ; Jump back to decrease the air supply again.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Add to the score                                               ;
;                                                                ;
; ---------------------------------------------------------------;

AddToTheScore                     LD (HL),48                               ; Roll the digit over from '9' to '0'.
                                  DEC HL                                   ; Point HL at the next digit to the left.
                                  LD A,L                                   ; Is this the 10000s digit?
                                  CP 42
                                  JR NZ,AddToTheScore1                     ; Jump if not.

; Willy has scored another 10000 points. Give him an extra life.

                                  LD A,8                                   ; Set the screen flash counter to 8.
                                  LD (ScreenFlashCounter),A
                                  LD A,(LivesRemaining)                    ; Increment the number of lives remaining.
                                  INC A
                                  LD (LivesRemaining),A

; HL points at the digit of the score (see 33833) to be incremented.

AddToTheScore1                    LD A,(HL)                                ; Pick up a digit of the score.
                                  CP 57                                    ; Is it '9'?
                                  JR Z,37098                               ; Jump if so.
                                  INC (HL)                                 ; Increment the digit.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move the conveyor in the current cavern                        ;
;                                                                ;
; ---------------------------------------------------------------;

MoveConveyorInTheCurrentCavern    LD HL,(ConveyorAddress)                  ; Pick up the address of the conveyor's location in the screen
                                                                           ; buffer at 28672.
                                  LD E,L                                   ; Copy this address to DE.
                                  LD D,H
                                  LD A,(ConveyorLength)                    ; Pick up the length of the conveyor.
                                  LD B,A                                   ; B will count the conveyor tiles.
                                  LD A,(ConveyorDirection)                 ; Pick up the direction of the conveyor.
                                  OR A                                     ; Is the conveyor moving right?
                                  JR NZ,MoveConveyorInTheCurrentCavern2    ; Jump if the conveyor moving right.

; The conveyor is moving left.

                                  LD A,(HL)                                ; Copy the first pixel row of the conveyor tile to A.
                                  RLC A                                    ; Rotate it left twice.
                                  RLC A
                                  INC H                                    ; Point HL at the third pixel row of the conveyor tile.
                                  INC H
                                  LD C,(HL)                                ; Copy this pixel row to C.
                                  RRC C                                    ; Rotate it right twice.
                                  RRC C
MoveConveyorInTheCurrentCavern1   LD (DE),A                                ; Update the first and third pixel rows of every conveyor tile
                                                                           ; in the screen buffer at 28672.
                                  LD (HL),C
                                  INC L
                                  INC E
                                  DJNZ MoveConveyorInTheCurrentCavern1
                                  RET

; The conveyor is moving right.

MoveConveyorInTheCurrentCavern2   LD A,(HL)                                ; Copy the first pixel row of the conveyor tile to A.
                                  RRC A                                    ; Rotate it right twice.
                                  RRC A
                                  INC H                                    ; Point HL at the third pixel row of the conveyor tile.
                                  INC H
                                  LD C,(HL)                                ; Copy this pixel row to C.
                                  RLC C                                    ; Rotate it left twice.
                                  RLC C
                                  JR MoveConveyorInTheCurrentCavern1       ; Jump back to update the first and third pixel rows of every
                                                                           ; conveyor tile.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Move and draw the Kong Beast in the current cavern             ;
;                                                                ;
; ---------------------------------------------------------------;

MoveDrawKongBeast                 LD HL,23558                              ; Flip the left-hand switch at (0,6) if Willy is touching it.
                                  CALL FlipSwitchInKongBeatsCavern
                                  LD A,(EugDirOrKongBeastStatus)           ; Pick up the Kong Beast's status.
                                  CP 2                                     ; Is the Kong Beast already dead?
                                  RET Z                                    ; Return if so.
                                  LD A,(29958)                             ; Pick up the sixth pixel row of the left-hand switch from the
                                                                           ; screen buffer at 28672.
                                  CP 16                                    ; Has the switch been flipped?
                                  JP Z,MoveDrawKongBeast10                 ; Jump if not.

; The left-hand switch has been flipped. Deal with opening up the wall if that is still in progress.

                                  LD A,(24433)                             ; Pick up the attribute byte of the tile at (11,17) in the
                                                                           ; buffer at 24064.
                                  OR A                                     ; Has the wall there been removed yet?
                                  JR Z,MoveDrawKongBeast5                  ; Jump if so.
                                  LD HL,32625                              ; Point HL at the bottom row of pixels of the wall tile at
                                                                           ; (11,17) in the screen buffer at 28672.
MoveDrawKongBeast3                LD A,(HL)                                ; Pick up a pixel row.
                                  OR A                                     ; Is it blank yet?
                                  JR NZ,MoveDrawKongBeast4                 ; Jump if not.
                                  DEC H                                    ; Point HL at the next pixel row up
                                  LD A,H                                   ; Have we checked all 8 pixel rows yet?
                                  CP 119
                                  JR NZ,MoveDrawKongBeast3                 ; If not, jump back to check the next one
                                  LD A,(BackgroundTile)                    ; Pick up the attribute byte of the background tile for
                                                                           ; the current cavern.
                                  LD (24433),A                             ; Change the attributes at (11,17) and (12,17) in the buffer at
                                                                           ; 24064 to match the background tile.
                                                                           ; (the wall there is now gone).
                                  LD (24465),A
                                  LD A,114                                 ; Update the seventh byte of the guardian definition so that
                                                                           ; the guardian moves through the opening in the wall.
                                  LD (32971),A
                                  JR MoveDrawKongBeast5

MoveDrawKongBeast4                LD (HL),0                                ; Clear a pixel row of the wall tile at (11,17) in the screen
                                                                           ; buffer at 28672.
                                  LD L,145                                 ; Point HL at the opposite pixel row of the wall tile one cell)
                                  LD A,H                                   ; down at (12,17).
                                  XOR 7
                                  LD H,A
                                  LD (HL),0                                ; Clear that pixel row as well.

; Now check the right-hand switch.

MoveDrawKongBeast5                LD HL,23570                              ; Flip the right-hand switch at (0,18) if Willy is touching it
                                                                           ; (and it hasn't already been flipped).
                                  CALL FlipSwitchInKongBeatsCavern
                                  JR NZ,MoveDrawKongBeast7                 ; Jump if the switch was not flipped.
                                  XOR A                                    ; Initialise the Kong Beast's pixel y-coordinate to 0.
                                  LD (MultiUseCoordinateStore),A
                                  INC A                                    ; Update the Kong Beast's status to 1: he is falling.
                                  LD (EugDirOrKongBeastStatus),A
                                  LD A,(BackgroundTile)                    ; Pick up the attribute byte of the background tile for the
                                                                           ; current cavern.
                                  LD (24143),A                             ; Change the attributes of the floor beneath the Kong Beast in
                                                                           ; the buffer at 24064 to match that of the background tile
                                  LD (24144),A
                                  LD HL,28751                              ; Point HL at (2,15) in the screen buffer at 28672.
                                  LD B,8                                   ; Clear the cells at (2,15) and (2,16), removing the floor
MoveDrawKongBeast6                LD (HL),0                                ; beneath the Kong Beast
                                  INC L
                                  LD (HL),0
                                  DEC L
                                  INC H
                                  DJNZ MoveDrawKongBeast6
MoveDrawKongBeast7                LD A,(EugDirOrKongBeastStatus)           ; Pick up the Kong Beast's status.
                                  OR A                                     ; Is the Kong Beast still on the ledge?
                                  JR Z,MoveDrawKongBeast10                 ; Jump if so.

; The Kong Beast is falling.

                                  LD A,(MultiUseCoordinateStore)           ; Pick up the Kong Beast's pixel y-coordinate.
                                  CP 100                                   ; Has he fallen into the portal yet?
                                  JR Z,MoveDrawKongBeast9                  ; Jump if so.
                                  ADD A,4                                  ; Add 4 to the Kong Beast's pixel y-coordinate
                                                                           ; (moving him downwards).
                                  LD (MultiUseCoordinateStore),A
                                  LD C,A                                   ; Copy the pixel y-coordinate to C; this value determines the
                                                                           ; pitch of the sound effect.
                                  LD D,16                                  ; This value determines the duration of the sound effect.
                                  LD A,(BorderColor)                       ; Pick up the border colour for the current cavern
MoveDrawKongBeast8                OUT (254),A                              ; Make a falling sound effect.
                                  XOR 24
                                  LD B,C
                                  DJNZ .
                                  DEC D
                                  JR NZ,MoveDrawKongBeast8
                                  LD A,C                                   ; Copy the Kong Beast's pixel y-coordinate back into A.
                                  RLCA                                     ; Point DE at the entry in the screen buffer address lookup
                                  LD E,A                                   ; table that corresponds to the Kong Beast's pixel y-coordinate.
                                  LD D,high YTable
                                  LD A,(DE)                                ; Point HL at the address of the Kong Beast's location in the
                                  OR 15                                    ; screen buffer at 24576.
                                  LD L,A
                                  INC DE
                                  LD A,(DE)
                                  LD H,A
                                  LD D,high GuardianGraphicData            ; Use bit 5 of the value of the game clock.
                                  LD A,(GameClock)                         ; (which is toggled once every eight passes through the main
                                  AND 32                                   ; loop) to point DE at the graphic data for the appropriate
                                  OR 64                                    ; Kong Beast sprite.
                                  LD E,A
                                  LD C,0                                   ; Draw the Kong Beast to the screen buffer at 24576.
                                  CALL DrawASprite
                                  LD HL,33836                              ; Add 100 to the score.
                                  CALL AddToTheScore1
                                  LD A,(MultiUseCoordinateStore)           ; Pick up the Kong Beast's pixel y-coordinate.
                                  AND 120                                  ; Point HL at the address of the Kong Beast's location in the
                                  LD L,A                                   ; attribute buffer at 23552.
                                  LD H,23
                                  ADD HL,HL
                                  ADD HL,HL
                                  LD A,L
                                  OR 15
                                  LD L,A
                                  LD A,6                                   ; The Kong Beast is drawn with yellow INK.
                                  JP SetAttributeMulti                     ; Set the attribute bytes for the Kong Beast.

; The Kong Beast has fallen into the portal.

MoveDrawKongBeast9                LD A,2                                   ; Set the Kong Beast's status to 2: he is dead.
                                  LD (EugDirOrKongBeastStatus),A
                                  RET

; The Kong Beast is still on the ledge.

MoveDrawKongBeast10               LD A,(GameClock)                         ; Pick up the value of the game clock.
                                  AND 32                                   ; Use bit 5 of this value (which is toggled once every eight
                                  LD E,A                                   ; passes through the main loop) to point DE at the graphic data
                                  LD D,high GuardianGraphicData            ; for the appropriate Kong Beast sprite.
                                  LD HL,24591                              ; Draw the Kong Beast at (0,15) in the screen buffer at 24576.
                                  LD C,1
                                  CALL DrawASprite
                                  JP NZ,KillWilly1                         ; Kill Willy if he collided with the Kong Beast.

                                  LD A,$44                                 ; A = 68 (INK 4: PAPER 0: BRIGHT 1)
                                  LD (23599),A                             ; Set the attribute bytes for the Kong Beast in the buffer
                                  LD (23600),A                             ; at 23552.
                                  LD (23567),A
                                  LD (23568),A
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ------------------------------------------------------------------------;
;                                                                         ;
; Flip a switch in a Kong Beast cavern if Willy is touching it.           ;
;                                                                         ;
; Input                                                                   ;
; ----------------------------------------------------------------------  ;
; HL | Address of the switch's location in the attribute buffer at 23552  ;
;                                                                         ;
; ------------------------------------------------------------------------;

; Returns with the zero flag set if Willy flips the switch.

FlipSwitchInKongBeatsCavern       LD A,(WillysLocInAttrBuffer)             ; Pick up the LSB of the address of Willy's location in the
                                                                           ; attribute buffer at 23552.
                                  INC A                                    ; Is it equal to or one less than the LSB of the address of
                                  AND 254                                  ; the switch's location?
                                  CP L                                     ;
                                  RET NZ                                   ; Return (with the zero flag reset) if not.
                                  LD A,(WillysLocInAttrBuffer+1)           ; Pick up the MSB of the address of Willy's location in the
                                                                           ; attribute buffer at 23552.
                                  CP H                                     ; Does it match the MSB of the address of the switch's location?
                                  RET NZ                                   ; Return (with the zero flag reset) if not.
                                  LD A,(ExtraTile+6)                       ; Pick up the sixth byte of the graphic data for the switch tile.
                                  LD H,117                                 ; Point HL at the sixth row of pixels of the switch tile in the
                                                                           ; screen buffer at 28672.
                                  CP (HL)                                  ; Has the switch already been flipped?
                                  RET NZ                                   ; Return (with the zero flag reset) if so.

; Willy is flipping the switch.

                                  LD (HL),8                                ; Update the sixth, seventh and eighth rows of pixels of the
                                  INC H                                    ; switch tile in the screen buffer at 28672 to make it appear
                                  LD (HL),6                                ; flipped.
                                  INC H                                    ;
                                  LD (HL),6                                ;
                                  XOR A                                    ; Set the zero flag: Willy has flipped the switch.
                                  OR A                                     ; This instruction is redundant.
                                  RET                                      ;

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Check and set the attribute bytes for Willy's sprite in the    ;
; buffer at 23552.                                               ;
;                                                                ;
; ---------------------------------------------------------------;

CheckSetAttributeForWSIB          LD HL,(WillysLocInAttrBuffer)            ; Pick up the address of Willy's location in the attribute.
                                                                           ; buffer at 23552.
                                  LD DE,31                                 ; Prepare DE for addition.
                                  LD C,15                                  ; Set C=15 for the top two rows of cells
                                                                           ; (to make the routine at CheckSetAttributeForCOBWS force
                                                                           ; white INK).
                                  CALL CheckSetAttributeForCOBWS           ; Check and set the attribute byte for the top-left cell.
                                  INC HL                                   ; Move HL to the next cell to the right.
                                  CALL CheckSetAttributeForCOBWS           ; Check and set the attribute byte for the top-right cell.
                                  ADD HL,DE                                ; Move HL down a row and back one cell to the left.
                                  CALL CheckSetAttributeForCOBWS           ; Check and set the attribute byte for the mid-left cell.
                                  INC HL                                   ; Move HL to the next cell to the right.
                                  CALL CheckSetAttributeForCOBWS           ; Check and set the attribute byte for the mid-right cell.
                                  LD A,(WillysPixelYCoord)                 ; Pick up Willy's pixel y-coordinate.
                                  LD C,A                                   ; Copy it to C.
                                  ADD HL,DE                                ; Move HL down a row and back one cell to the left.
                                  CALL CheckSetAttributeForCOBWS           ; Check and set the attribute byte for the bottom-left cell.
                                  INC HL                                   ; Move HL to the next cell to the right.
                                  CALL CheckSetAttributeForCOBWS           ; Check and set the attribute byte for the bottom-right cell.
                                  JR DrawWillyToScreenBuffer               ; Draw Willy to the screen buffer at 24576.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Check and set the attribute byte for a cell occupied by        ;
; Willy's sprite.                                                ;
;                                                                ;
; Input                                                          ;
; ----------------------------------------------------------     ;
;  C | 15 or Willy's pixel y-coordinate.                         ;
; HL | Address of the cell in the attribute buffer at 23552.     ;
; ---------------------------------------------------------------;

CheckSetAttributeForCOBWS         LD A,(BackgroundTile)                    ; Pick up the attribute byte of the background tile for the
                                                                           ; current cavern.
                                  CP (HL)                                  ; Does this cell contain a background tile?
                                  JR NZ,CheckSetAttributeForCOBWS1         ; Jump if not.

                                  LD A,C                                   ; Set the zero flag if we are going to retain the INK colour in
                                                                           ; this cell; this happens only if the cell is in the bottom row
                                                                           ; and Willy's sprite is confined to the top two rows.
                                  AND $0F
                                  JR Z,CheckSetAttributeForCOBWS1          ; Jump if we are going to retain the current INK colour in this cell

                                  LD A,(BackgroundTile)                    ; Pick up the attribute byte of the background tile for the
                                                                           ; current cavern;
                                  OR 7                                     ; Set bits 0-2, making the INK white.
                                  LD (HL),A                                ; Set the attribute byte for this cell in the buffer at 23552.
CheckSetAttributeForCOBWS1        LD A,(NastyTile1)                        ; Pick up the attribute byte of the first nasty tile
                                  CP (HL)                                  ; Has Willy hit a nasty of the first kind?
                                  JP Z,KillWilly                           ; Kill Willy if so.

                                  LD A,(NastyTile2)                        ; Pick up the attribute byte of the second nasty tile
                                  CP (HL)                                  ; Has Willy hit a nasty of the second kind?
                                  JP Z,KillWilly                           ; Kill Willy if so
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Draw Willy to the screen buffer at 24576.                      ;
;                                                                ;
; ---------------------------------------------------------------;

DrawWillyToScreenBuffer           LD A,(WillysPixelYCoord)                 ; Pick up Willy's pixel y-coordinate.
                                  LD IXH,high YTable                       ; Point IX at the entry in the screen buffer address lookup table
                                                                           ; y-coordinate.
                                  LD IXL,A
                                  LD A,(WillysDirAndMovFlags)              ; Pick up Willy's direction and movement flags.
                                  AND 1                                    ; Now E=0 if Willy is facing right, or 128 if he's facing left.
                                  RRCA
                                  LD E,A
                                  LD A,(WillysAnimationFrame)              ; Pick up Willy's animation frame (0-3).
                                  AND 3                                    ; Point DE at the sprite graphic data for Willy's current
                                                                           ; animation frame.
                                  RRCA
                                  RRCA
                                  RRCA
                                  OR E
                                  LD E,A
                                  LD D,high WillySpriteData
                                  LD B,16                                  ; There are 16 rows of pixels to copy.
                                  LD A,(WillysLocInAttrBuffer)             ; Pick up Willy's screen x-coordinate (0-31).
                                  AND $1F
                                  LD C,A                                   ; Copy it to C.
DrawWillyToScreenBuffer1          LD A,(IX+0)                              ; Set HL to the address in the screen buffer at 24576 that
                                                                           ; corresponds to where we are going to draw the next pixel row
                                                                           ; of the sprite graphic.
                                  LD H,(IX+1)
                                  OR C
                                  LD L,A
                                  LD A,(DE)                                ; Pick up a sprite graphic byte.
                                  OR (HL)                                  ; Merge it with the background.
                                  LD (HL),A                                ; Save the resultant byte to the screen buffer.
                                  INC HL                                   ; Move HL along to the next cell to the right.
                                  INC DE                                   ; Point DE at the next sprite graphic byte.
                                  LD A,(DE)                                ; Pick it up in A.
                                  OR (HL)                                  ; Merge it with the background.
                                  LD (HL),A                                ; Save the resultant byte to the screen buffer.
                                  INC IX                                   ; Point IX at the next entry in the screen buffer address lookup
                                                                           ; table.
                                  INC IX
                                  INC DE                                   ; Point DE at the next sprite graphic byte.
                                  DJNZ DrawWillyToScreenBuffer1            ; Jump back until all 16 rows of pixels have been drawn.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Print a message                                                ;
;                                                                ;
; Input                                                          ;
; ---------------------------                                    ;
; IX = Address of the message                                    ;
;  C = Length of the message                                     ;
; DE = Display file address                                      ;
;                                                                ;
; ---------------------------------------------------------------;

PrintAMessage                     LD A,(IX+0)                              ; Collect a character from the message.
                                  CALL PrintASingleCharacter               ; Print it.
                                  INC IX                                   ; Point IX at the next character in the message.
                                  INC E                                    ; Point DE at the next character cell.
                                                                           ; Subtracting 8 from D compensates for the operations performed.
                                                                           ; by the routine at PrintASingleCharacter.
                                  LD A,D
                                  SUB 8
                                  LD D,A
                                  DEC C                                    ; Have we printed the entire message yet?
                                  JR NZ,PrintAMessage                      ; If not, jump back to print the next character.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Print a single character.                                      ;
;                                                                ;
; Input                                                          ;
; --------------------------------                               ;
;  A = ASCII code of the character                               ;
; DE = Display file address                                      ;
;                                                                ;
; ---------------------------------------------------------------;

PrintASingleCharacter             LD H,7                                   ; Point HL at the bitmap for the character (in the ROM).
                                  LD L,A
                                  SET 7,L
                                  ADD HL,HL
                                  ADD HL,HL
                                  ADD HL,HL
                                  LD B,8                                   ; There are eight pixel rows in a character bitmap.

; ---------------------------------------------------------------;
;                                                                ;
; Draw an item in the current cavern.                            ;
;                                                                ;
; ---------------------------------------------------------------;

DrawItem                          LD A,(HL)                                ; Copy the character bitmap to the screen (or item graphic to
                                  LD (DE),A                                ; the screen buffer).
                                  INC HL
                                  INC D
                                  DJNZ DrawItem
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Play the theme tune (The Blue Danube)                          ;
;                                                                ;
; Returns with the zero flag reset if ENTER or the fire button   ;
; is pressed while the tune is being played.                     ;
;                                                                ;
; Input                                                          ;
; ------------------------                                       ;
; IY = TitleScreenTuneData                                       ;
;                                                                ;
; ---------------------------------------------------------------;

PlayTheThemeTune                  LD A,(IY+0)                              ; Pick up the next byte of tune data from the table at
                                                                           ; TitleScreenTuneData.
                                  CP $FF                                   ; Has the tune finished?
                                  RET Z                                    ; Return (with the zero flag set) if so.
                                  LD C,A                                   ; Copy the first byte of data for this note.
                                                                           ; (which determines the duration) to C.
                                  LD B,0                                   ; Initialise B, which will be used as a delay counter in the
                                                                           ; note-producing loop.
                                  XOR A                                    ; Set A = 0 (for no apparent reason).
                                  LD D,(IY+1)                              ; Pick up the second byte of data for this note.
                                  LD A,D                                   ; Copy it to A.
                                  CALL CalcAFAForPianoKey                  ; Calculate the attribute file address for the corresponding
                                                                           ; piano key.
                                  LD (HL),80                               ; Set the attribute byte for the piano key to 80
                                                                           ; (INK 0: PAPER 2: BRIGHT 1).
                                  LD E,(IY+2)                              ; Pick up the third byte of data for this note.
                                  LD A,E                                   ; Copy it to A.
                                  CALL CalcAFAForPianoKey                  ; Calculate the attribute file address for the corresponding
                                                                           ; piano key.
                                  LD (HL),40                               ; Set the attribute byte for the piano key to 40
                                                                           ; (INK 0: PAPER 5: BRIGHT 0).
PlayTheThemeTune1                 OUT (254),A                              ; Produce a sound based on the frequency parameters in the
                                                                           ; second and third bytes of data for this note
                                                                           ; (copied into D and E).
                                  DEC D
                                  JR NZ,PlayTheThemeTune2

                                  LD D,(IY+1)
                                  XOR 24
PlayTheThemeTune2                 DEC E
                                  JR NZ,PlayTheThemeTune3
                                  LD E,(IY+2)
                                  XOR 24
PlayTheThemeTune3                 DJNZ PlayTheThemeTune1
                                  DEC C
                                  JR NZ,PlayTheThemeTune1
                                  CALL IsEnterOrFireButtonPressed          ; Check whether ENTER or the fire button is being pressed.
                                  RET NZ                                   ; Return (with the zero flag reset) if it is.
                                  LD A,(IY+1)                              ; Pick up the second byte of data for this note.
                                  CALL CalcAFAForPianoKey                  ; Calculate the attribute file address for the corresponding
                                                                           ; piano key.
                                  LD (HL),56                               ; Set the attribute byte for the piano key back to 56
                                                                           ; (INK 0: PAPER 7: BRIGHT 0).
                                  LD A,(IY+2)                              ; Pick up the third byte of data for this note.
                                  CALL CalcAFAForPianoKey                  ; Calculate the attribute file address for the corresponding
                                                                           ; piano key.
                                  LD (HL),56                               ; Set the attribute byte for the piano key back to 56
                                                                           ; (INK 0: PAPER 7: BRIGHT 0).
                                  INC IY                                   ; Move IY along to the data for the next note in the tune.
                                  INC IY
                                  INC IY
                                  JR PlayTheThemeTune                      ; Jump back to play the next note.

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Calculate the attribute file address for a piano key.          ;
;                                                                ;
; Returns with the attribute file address in HL.                 ;
;                                                                ;
; Input                                                          ;
; ---------------------------------------------------            ;
; A = Frequency parameter from the tune data table at            ;
;     TitleScreenTuneData                                        ;
;                                                                ;
; ---------------------------------------------------------------;

CalcAFAForPianoKey                SUB 8                                    ; Compute the piano key index (K) based on the frequency.
                                  RRCA                                     ; parameter (F) and store it in bits 0-4 of A:
                                  RRCA                                     ; K = 31 - INT((F - 8) / 8).
                                  RRCA
                                  CPL
                                  OR $E0                                   ; A = 224 + K ; this is the LSB.
                                  LD L,A                                   ; Set HL to the attribute file address for the piano key.
                                  LD H,89
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Check whether ENTER or the FIRE button is being pressed        ;
;                                                                ;
; ---------------------------------------------------------------;

; Returns with the zero flag reset if ENTER or the fire button on the joystick is being pressed.

IsEnterOrFireButtonPressed        LD A,(KempJoystickIndicator)             ; Pick up the Kempston joystick indicator.
                                  OR A                                     ; Is the joystick connected?
                                  JR Z,IsEnterOrFireButtonPressed1         ; Jump if not.
                                  IN A,(31)                                ; Collect input from the joystick.
                                  BIT 4,A                                  ; Is the fire button being pressed?
                                  RET NZ                                   ; Return (with the zero flag reset) if so.
IsEnterOrFireButtonPressed1       LD BC,zeuskeyaddr("HJKL[ENTER]")         ; Read keys H-J-K-L-ENTER.
                                  IN A,(C)
                                  AND 1                                    ; Keep only bit 0 of the result (ENTER).
                                  CP 1                                     ; Reset the zero flag if ENTER is being pressed.
                                  RET

; ------------------------------------------------------------------------------------------------------------------------------------------;
                                  ORG $9CFE                                ; Some space here used by the stack

                                 ;DS 2482                                  ; If you don't want to fix

MemTop                            DEFB 9,'A'                               ; The remains of "AND 7"

; ---------------------------------------------------------------;
;                                                                ;
; Title screen banner.                                           ;
;                                                                ;
; ---------------------------------------------------------------;

; This must be page-aligned

                                  ALIGN $100

TitleScreenBanner                 DEFM ".  .  .  .  .  .  .  .  .  .  . MANIC MINER . . "
                                  DEFM 127," BUG-BYTE ltd. 1983 . . By Matthew Smith . . . "
                                  DEFM "Q to P = Left & Right . . Bottom row = Jump . . "
                                  DEFM "A to G = Pause . . H to L = Tune On/Off . . . "
                                  DEFM "Guide Miner Willy through 20 lethal caverns"
                                  DEFM " .  .  .  .  .  .  .  ."  ;

; ------------------------------------------------------------------------------------------------------------------------------------------;

; ---------------------------------------------------------------;
;                                                                ;
; Attribute data for the bottom two-thirds of the title screen.  ;
;                                                                ;
; ---------------------------------------------------------------;

BottomAttributes                  DH "1616161616161616161616161616161616161616161616161616161616161616"
                                  DH "1717171717171717171717171717171717171717171010101010101010171717"
                                  DH "1717171717171717171717171717171717171717171616161616161616171717"
                                  DH "1313131313131313131313131313131313131313131313131313131313131313"
                                  DH "1717171717171010101010101616161616101010101010101010101010101010"
                                  DH "1010101010101010101010101010101010101010101010101010101010101010"
                                  DH "3838383838383838383838383838383838383838383838383838383838383838"
                                  DH "3838383838383838383838383838383838383838383838383838383838383838"
                                  DH "3030303030303030303030303030303030303030303030303030303030303030"
                                  DH "5757575757575757575767676767676767676767676767676767676767676767"
                                  DH "4646464646464646464646464646464646464646464646464646464646464646"
                                  DH "4646464646464646464646464646464646464646464646464646464646464646"
                                  DH "4646464646464646464646464646464646464646464646464646464646464646"
                                  DH "4545454545454545454545454545454545454545454545454545454545454545"
                                  DH "4545454545454545454545454545454545454545454545454545454545454545"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"

; ---------------------------------------------------------------;
;                                                                ;
; The graphics data for the top two-thirds of the title screen.  ;
;                                                                ;
; ---------------------------------------------------------------;

TitleScreenDataTop                DH "050000000000E000000000000000000000000000000001818180000000000000"
                                  DH "3B0008630000E000000000000000000000000000000000FFFF0000000007FFE0"
                                  DH "0300005400FF000007E000000FDFDC0000000000000000FFFF0022222208E010"
                                  DH "00FF9F94F3003FC01FF803FC000000000024424224440000000077777700FF00"
                                  DH "0000008A0007FFFC07E03FFFE000000000000000000000000000000000000000"
                                  DH "0000004A00000001FFFF800000E0000000000000000000000000000000000000"
                                  DH "010001B98030FFFF07C0FFFF0FFF000000000000000000000000000000000000"
                                  DH "0124001240124012400122401141021024102100001000000000000000000021"
                                  DH "070000000000F8000000000000000000000000000000034242C0000000000000"
                                  DH "160000000000C8000000000001F0000000000000000000FFFF00000000040020"
                                  DH "0500005500FF00007FFE00000FEF780000000000000000818100777777091010"
                                  DH "007F0F55F4007FE01FF807FE000000000024424422420000000077777731FF8C"
                                  DH "000000520001FFFE07E07FFF8000000F00000000000000000000000000000000"
                                  DH "0000005200700003FFFFC0000EF0000000000000000000000000000000000000"
                                  DH "0700031000307FFF01F0FFFC01FF000000000000000000000000000000000000"
                                  DH "0124302151302431202042103421031202134000004200000000000000000031"
                                  DH "030000000000D0000000000000000000000000000000072424E0000000000000"
                                  DH "1D0000000000B4000000000007F8000000000000000000818100000000041820"
                                  DH "0500009400D000007FFE00001FFF978000657656865600818100777777095010"
                                  DH "003E0755C000FFE01FF807FF000000000022424424420000000077777732FF4C"
                                  DH "0000005100007FFE00007FFE000000FF00000000000000000000000000000000"
                                  DH "00000652307F0003FFFFC000FEF8000000000000000000000000000000000000"
                                  DH "0F00000000003FFF07E0FFF0003F000000000000000000000000000000000000"
                                  DH "0213150243602134503121503761502812034600002400000000000000000027"
                                  DH "010000000000E00000000000000000000000000000000F1818F0000000000000"
                                  DH "1F0000000000F600000000000FFC000000000000000000818100000000040020"
                                  DH "170000A200F800007FFE00001FFFEF5C70859754686700818100FFFFFF3FFFFC"
                                  DH "00140254C001FFF01FF80FFF800000000042442224220000000077777734FF2C"
                                  DH "0000009500001FFF0000FFF800000FFF00000000000000000000000000000000"
                                  DH "00000F51F87FF007FFFFE00FFEF8000000000000000000000000000000000000"
                                  DH "0F00000000001E7F03F0FF800003000000000000000000000000000000000000"
                                  DH "2130543067289120345190243154612034519000008300000000000000000073"
                                  DH "060000000000E40000000000000000000000000000001F1818F8000000000000"
                                  DH "05000781C030C800000000001E3BB00000000000000000818100000000040020"
                                  DH "1D0000AA00C000003FFC00000E7FEEDEF8666666666600818100FFFFFF7FFFFE"
                                  DH "000000928001FFF00FF00FFF80000000004224424244000000007777773FFFFC"
                                  DH "000000A5000007FF03C0FFE000003FFF00000000000000000000000000000000"
                                  DH "00007F89FC7FFF07FFFFE0FFFEFC000000000000000000000000000000000000"
                                  DH "3F0000000000001F0180FE000000C10000000000000000000000000000000000"
                                  DH "7411579151210246191202491206742134612100002100000000000000000043"
                                  DH "0B0000000000D00000000000000000000000000000003F2424FC000000000000"
                                  DH "030002C3A000D000000000001DD7D80000000000000000818100000000040020"
                                  DH "1F0000AA008001803FFC01800FBFEEDEF8666666666600818100777777FFFFFF"
                                  DH "0000008A0003FFF80FF01FFFC00000000024422424240000000077777730FF0C"
                                  DH "000000A9000001FE1FF87F800000FFFF00000000000000000000000000000000"
                                  DH "0001FFAAFCFFFFC7FFFFE3FFFFFE000000000000000000000000000000000000"
                                  DH "FF0000000000000F0FC0F00000003E0000000000000000000000000000000000"
                                  DH "F8102F4621711546312615421315032434515100005100000000000000000024"
                                  DH "050000000000B40000000000000000000000000000007F4242FE000000000000"
                                  DH "06000153C000B800000000000BEFE80000000000000000818100000000000020"
                                  DH "0A0000AA000007803FFC01E007DFCF6F78666666666600FFFF00777777FFFFFF"
                                  DH "000000AA0003FFF80FF01FFFC000000000224244224200000000777777303C0C"
                                  DH "000000AA0000007C7FFE3E00000FFFFF00000000000000000000000000000000"
                                  DH "000FFFAAFEFFFFCFFFFFF3FFFFFE000000000000000000000000000000000000"
                                  DH "FF0000000000000703F0E0000000000000000000000000000000000000000000"
                                  DH "0120312033203120021042101240104240104200008200000000000000000040"
                                  DH "2A0000000000F8000000000000000000000000000000FF8181FF000000000000"
                                  DH "030000A3000064000000000007DFEC0000000000000000FFFF00000000040020"
                                  DH "070000A200001FC03FFC03F8038F87BFF0666666666600FFFF00777777FFFFFF"
                                  DH "000000AA0007FFFC0FF03FFFE00000007EA6F6A6F6A60000000077777730000C"
                                  DH "0000008A00000018FFFF180000FFFFFF00000000000000000000000000000000"
                                  DH "003FFF4AFFFFFFCFFFFFF3FFFFFF000000000000000000000000000000000000"
                                  DH "FF0000000000000101C080000000000000000000000000000000000000000000"
                                  DH "FCBDFEBCFDBECBDFEBCFCDEFCFBFFECDBCCEBD0000DB000000000000000000BD"
                                  DH "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "0000820C3F861E3380000022318C3C600C606000008BA2FBC08BA08880000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000FCFCFE7C7C00FEC6FEFEFC00FE7C007CFE10FCFE000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "0041000C60C60E3181000020318C1C604C30700000D932822089208500000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000FEFEFEFEFE00FEE6FEFEFE00FEFE00FEFE38FEFE000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "4444444444444444444444444444444444444444444444444444444444444444"
                                  DH "0003FF1E040E0F783A0007F83BDC1EFF9FF000000001FF88F3CE89FF80000000"
                                  DH "0082000C40C60630C6000020318C0C618C18100000A92AE3C0A9208200000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000C6C6C0C2C200C0F630C0C60030C600C2306CC630000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "1111111111111111111111111111111111111111111111111111111111111111"
                                  DH "0006073C0E070630C6000838718E0C618C380000000204148A24CA0000000000"
                                  DH "008C001EE1EF0278380000707BDE04FF9E0E20000089268280A9208200000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000FEFEF0F8F800F0F630F0FE0030C600F830C6FE30000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "00098B6C0E0786318300102C718F0C604C1800000001C422F3C4AA6000000000"
                                  DH "007000000000000000000000000000000007C000008BA2FA6053BEFA00000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000FCFCF03E3E00F0DE30F0FC0030C6003E30C6FC30000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000993CC1B06C6338000102CB18D8C620C1800000000243EA2849A2000000000"
                                  DH "FF07FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01FF0000000000000000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000C0D8C0868600C0DE30C0D80030C6008630FED830000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "0006238C1306663300001326B18CCC7E0FF0000000FFC4229A6E89C000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000C0CCFEFEFE00FECE30FECC0030FE00FE30FECC30000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "0000430C3186363300000C27318C6C620CC00000000000000000000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "000000000000C0C6FE7C7C00FEC630FEC600307C007C30C6C630000000000000"
                                  DH "0000000000000000000000000000000000000000000000000000000000000000"
                                  DH "07C7C7C107C7C107C7C7C107C7C107C7C107C7C7C107C7C107C7C7C107C7C101"
                                  DH "0101010101010101010101010101010101010101010101010101010101010101"

; ------------------------------------------------------------------------------------------------------------------------------------------;

                                  ALIGN $400                               ; Cavern data must be aligned on 1K boundaries
; ---------------------------------------------------------------;
;                                                                ;
; Central Cavern (teleport: 6)                                   ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

CentralCavernData                 DH "1600000000000000000000050000000005000000000000000000000000000016"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "1600000000000000000000000000000000000000000000440000004400000016"
                                  DH "1642424242424242424242424242020202024202020202424242424242424216"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "1642424200000000000000000000000000000000000000000000000000000016"
                                  DH "1600000000000000000000000000000000161616004400000000000000000016"
                                  DH "1642424242000000040404040404040404040404040404040404040400000016"
                                  DH "1600000000000000000000000000000000000000000000000000000000424216"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "1600000000000000000000004400000000000000161616020202020242424216"
                                  DH "1600000000424242424242424242424242424242000000000000000000000016"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "1642424242424242424242424242424242424242424242424242424242424216"

; The next 32 bytes specify the cavern name.

                                  DEFM "         Central Cavern         "  ; Cavern name

; Background
                                  db $00
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------

; Floor
                                  db $42
                                  dg ########
                                  dg ########
                                  dg ##-##-##
                                  dg -##-###-
                                  dg ##---#-#
                                  dg -#------
                                  dg --------
                                  dg --------

; Crumbling floor
                                  db $02
                                  dg ########
                                  dg ##-##-##
                                  dg #-#--#-#
                                  dg --#--#--
                                  dg -#-#--#-
                                  dg --#-----
                                  dg ----#---
                                  dg --------

; Wall
                                  db $16
                                  dg --#---#-
                                  dg ########
                                  dg #---#---
                                  dg ########
                                  dg --#---#-
                                  dg ########
                                  dg #---#---
                                  dg ########

; Conveyor
                                  db $04
                                  dg ####----
                                  dg -##--##-
                                  dg ####----
                                  dg -##--##-
                                  dg --------
                                  dg #--##--#
                                  dg ########
                                  dg --------

; Nasty 1
                                  db $44
                                  dg -#---#--
                                  dg --#-#---
                                  dg #--#-#--
                                  dg -#-#---#
                                  dg --##-#-#
                                  dg ##-#-##-
                                  dg -#-##---
                                  dg ---#----

; Nasty 2
                                  db $05
                                  dg ########
                                  dg #######-
                                  dg -######-
                                  dg -#####--
                                  dg -#--##--
                                  dg -#--##--
                                  dg ----#---
                                  dg ----#---

; Extra
                                  db $00
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.

                                  DEFB 208                                 ; Pixel y-coordinate * 2.
                                  DEFB 0                                   ; Animation frame.
                                  DEFB 0                                   ; Direction and movement flags: facing right.
                                  DEFB 0                                   ; Airborne status indicator.
                                  DEFW 23970                               ; Location in the attribute buffer at 23970 : (13,2).
                                  DEFB 0                                   ; Jumping animation counter.

; The next four bytes specify the direction, location and length of the conveyor.

                                  DEFB 0                                   ; Direction (left).
                                  DEFW 30760                               ; Location in the screen buffer : (9,8).
                                  DEFB 20                                  ; Length.

; The next byte specifies the border colour.

                                  DEFB 2                          ; Border colour.

                                  DEFB 0                          ; Unused.

; The next 25 bytes specify the location and initial colour of the items in the cavern.

                                  DEFB 3                          ; Item 1 at (0,9).
                                  DEFW 23561
                                  DEFB 96
                                  DEFB 255
                                  DEFB 4                          ; Item 2 at (0,29).
                                  DEFW 23581
                                  DEFB 96
                                  DEFB 255
                                  DEFB 5                          ; Item 3 at (1,16).
                                  DEFW 23600
                                  DEFB 96
                                  DEFB 255
                                  DEFB 6                          ; Item 4 at (4,24).
                                  DEFW 23704
                                  DEFB 96
                                  DEFB 255
                                  DEFB 3                          ; Item 5 at (6,30).
                                  DEFW 23774
                                  DEFB 96
                                  DEFB 255
                                  DEFB 255                        ; Terminator.

; The next 37 bytes define the portal graphic and its location.
; Portal

                        db $0E
                        dg ################
                        dg #--#--#--#--#--#
                        dg #-##-##-##-##-##
                        dg ################
                        dg #--#--#--#--#--#
                        dg #-##-##-##-##-##
                        dg ################
                        dg #--#--#--#--#--#
                        dg #-##-##-##-##-##
                        dg ################
                        dg #--#--#--#--#--#
                        dg #-##-##-##-##-##
                        dg ################
                        dg #--#--#--#--#--#
                        dg #-##-##-##-##-##
                        dg ################

                        dw $5DBD,$68BD

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; The next byte specifies the initial air supply in the cavern.

                        DEFB 63                         ; Air.

; The next byte initialises the game clock.

                        DEFB 252                        ; Game clock.

; The next 28 bytes define the horizontal guardians.

                        DEFB 70                         ; Horizontal guardian 1: y=7, initial x=8, 8<=x<=15, speed=normal.
                        DEFW 23784
                        DEFB 96
                        DEFB 0
                        DEFB 232
                        DEFB 239
                        DEFB 255,0,0,0,0,0,0            ; Horizontal guardian 2 (unused).
                        DEFB 0,0,0,0,0,0,0              ; Horizontal guardian 3 (unused).
                        DEFB 0,0,0,0,0,0,0              ; Horizontal guardian 4 (unused).
                        DEFB 255                        ; Terminator.

; The next two bytes are not used.

                        DEFB 0,0                        ; Unused.

; The next byte indicates that there are no vertical guardians in this cavern.

                                   DEFB 255                                ; Terminator.

; The next two bytes are unused.

                                   DEFB 0,0                                ; Unused.

; The next 32 bytes define the swordfish graphic that appears in The Final Barrier when the game is completed.

SwordfishGraphicData              DEFB 2,160,5,67,31,228,115,255           ; Swordfish graphic data.
                                  DEFB 242,248,31,63,255,228,63,195
                                  DEFB 0,0,1,0,57,252,111,2
                                  DEFB 81,1,127,254,57,252,1,0

; The next 256 bytes define the guardian graphics.

                                  dg ---#####--#-----
                                  dg --###--####-----
                                  dg ---##--####-----
                                  dg ----####--#-----
                                  dg #--#####--------
                                  dg -#-######-------
                                  dg ##########------
                                  dg -#-####---------
                                  dg #--#######------
                                  dg ---######-------
                                  dg ----###---------
                                  dg ---#####--------
                                  dg #-###-###-#-----
                                  dg -###---###------
                                  dg --#-----#-------
                                  dg ---#---#--------

                                  dg -----#####---#--
                                  dg ----###--#####--
                                  dg -----##--#####--
                                  dg --#---####---#--
                                  dg ---#-#####------
                                  dg ---#-######-----
                                  dg --##########----
                                  dg ---#-#######----
                                  dg ---#-#######----
                                  dg --#--######-----
                                  dg ------###-------
                                  dg ------###-------
                                  dg -----##-##------
                                  dg -----##-##------
                                  dg ---###---###----
                                  dg -----##-##------

                                  dg -------#####--#-
                                  dg ------###--####-
                                  dg -------##--####-
                                  dg --------####--#-
                                  dg ----#--#####----
                                  dg -----#-######---
                                  dg ----##########--
                                  dg -----#-####-----
                                  dg ----#--#######--
                                  dg -------######---
                                  dg --------###-----
                                  dg --------###-----
                                  dg --------###-----
                                  dg --------###-----
                                  dg --------###-----
                                  dg -------#####----

                                  dg ---------#####-#
                                  dg --------###--###
                                  dg ---------##--###
                                  dg ----------####-#
                                  dg ---------#####--
                                  dg ---------#######
                                  dg ------########--
                                  dg ---------####---
                                  dg ---------#####--
                                  dg ---------#######
                                  dg ----------###---
                                  dg ----------###---
                                  dg ---------##-##--
                                  dg ---------##-##--
                                  dg -------###---###
                                  dg ---------##-##--

                                  dg #-#####---------
                                  dg ###--###--------
                                  dg ###--##---------
                                  dg #-####----------
                                  dg --#####---------
                                  dg #######---------
                                  dg --########------
                                  dg ---####---------
                                  dg --#####---------
                                  dg #######---------
                                  dg ---###----------
                                  dg ---###----------
                                  dg --##-##---------
                                  dg --##-##---------
                                  dg ###---###-------
                                  dg --##-##---------

                                  dg -#--#####-------
                                  dg -####--###------
                                  dg -####--##-------
                                  dg -#--####--------
                                  dg ----#####--#----
                                  dg ---######-#-----
                                  dg --##########----
                                  dg -----####-#-----
                                  dg --#######--#----
                                  dg ---######-------
                                  dg -----###--------
                                  dg -----###--------
                                  dg -----###--------
                                  dg -----###--------
                                  dg -----###--------
                                  dg ----#####-------

                                  dg --#---#####-----
                                  dg --#####--###----
                                  dg --#####--##-----
                                  dg --#---####---#--
                                  dg ------#####-#---
                                  dg -----######-#---
                                  dg ----##########--
                                  dg ----#######-#---
                                  dg ----#######-#---
                                  dg -----######--#--
                                  dg -------###------
                                  dg -------###------
                                  dg ------##-##-----
                                  dg ------##-##-----
                                  dg ----###---###---
                                  dg ------##-##-----

                                  dg -----#--#####---
                                  dg -----####--###--
                                  dg -----####--##---
                                  dg -----#--####----
                                  dg --------#####--#
                                  dg -------######-#-
                                  dg ------##########
                                  dg ---------####-#-
                                  dg ------#######--#
                                  dg -------######---
                                  dg ---------###----
                                  dg --------#####---
                                  dg -----#-###-###-#
                                  dg ------###---###-
                                  dg -------#-----#--
                                  dg --------#---#---

; ---------------------------------------------------------------;
;                                                                ;
; The Cold Room (teleport: 16)                                   ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

TheColdRoomData         DH "1608080808080808080808080808080808080816161616161616161616161616"
                        DH "1608080808080808080808080808080808080808080808080808080808080D16"
                        DH "1608080808080808080808080808080808080808080808080808080808080816"
                        DH "1608080808080808080808080808080808080808080B0B0B4B08080808080816"
                        DH "1608080808080808080808080808080808080808080808080808080808080816"
                        DH "164B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B080808080808080816080816"
                        DH "1608080808080808080808080808080808080808084B4B4B4B160B0B16080816"
                        DH "164B0B0B0B0B0B08080808080808080808080808080808080816080816080816"
                        DH "16080808080808080808080808080808080808080808080808160B0B16080816"
                        DH "1608080808080808084B4B4B4B4B4B4B080808080808080808160B0B16080816"
                        DH "160808080808080808080808080808080808080B0B0B0B0808160B0B16080816"
                        DH "1608080E0E0E0E080808080808080808080808080808080808160B0B16080816"
                        DH "16080808080808080808080808084B4B4B4B08080808080808160B0B16080816"
                        DH "16080808080808080B0B0B0B0808080808080808080808080808080808080816"
                        DH "1608080808080808080808080808080808080808080808080808080808080816"
                        DH "164B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B16"

; The next 32 bytes specify the cavern name.

                        DEFM "          The Cold Room         " ; Cavern name

; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.

; Background
                        db $08                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $4B                                ; K
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $0B                                ; .
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $16                                ; .
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $0E                                ; .
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg #--##--#
                        dg ########
                        dg --------

; Nasty 1
                        db $0C                                ; .
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $0D                                ; .
                        dg ########
                        dg #######-
                        dg -#-####-
                        dg -##-##--
                        dg -#--##--
                        dg -#--##--
                        dg ----#---
                        dg ----#---

; Extra
                        db $00                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.

                        DEFB 208                        ; Pixel y-coordinate * 2
                        DEFB 0                          ; Animation frame
                        DEFB 0                          ; Direction and movement flags: facing right
                        DEFB 0                          ; Airborne status indicator
                        DEFW 23970                      ; Location in the attribute buffer at 23552: (13,2)
                        DEFB 0                          ; Jumping animation counter

; The next four bytes specify the direction, location and length of the conveyor.

                        DEFB 1                          ; Direction (right)
                        DEFW 30819                      ; Location in the screen buffer at 28672: (11,3)
                        DEFB 4                          ; Length

; The next byte specifies the border colour.

                        DEFB 2                          ; Border colour

; The next byte is not used.

                        DEFB 0                          ; Unused

; The next 25 bytes specify the location and initial colour of the items in the cavern.

                        DEFB 11                         ; Item 1 at (1,7)
                        DEFW 23591                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 12                         ; Item 2 at (1,24)
                        DEFW 23608                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 13                         ; Item 3 at (7,26)
                        DEFW 23802                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 14                         ; Item 4 at (9,3)
                        DEFW 23843                      ;
                        DEFB 104                        ;
                        DEFB 255                        ;
                        DEFB 11                         ; Item 5 at (12,19)
                        DEFW 23955                      ;
                        DEFB 104                        ;
                        DEFB 255                        ;
                        DEFB 255                        ; Terminator

; The next 37 bytes define the portal graphic and its location.
                        db $53
                        dg ################
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg #--#--#--#--#--#
                        dg ################
; Location
                        dw $5DBD,$68BD

; Item graphic

                        dg -#-#----
                        dg #-#-#---
                        dg -#-#-#--
                        dg #-#-#---
                        dg -#-#-#--
                        dg --#-##--
                        dg ------#-
                        dg -------#


; The next byte specifies the initial air supply in the cavern.

                        DEFB 63                         ; Air

; The next byte initialises the game clock.

                        DEFB 252                        ; Game clock

; The next 28 bytes define the horizontal guardians.

                        DEFB 14                         ; Horizontal guardian 1: y=3, initial x=18, 1<=x<=18, speed=normal
                        DEFW 23666                      ;
                        DEFB 96                         ;
                        DEFB 7                          ;
                        DEFB 97                         ;
                        DEFB 114                        ;
                        DEFB 13                         ; Horizontal guardian 2: y=13, initial x=29, 12<=x<=29, speed=normal
                        DEFW 23997                      ;
                        DEFB 104                        ;
                        DEFB 7                          ;
                        DEFB 172                        ;
                        DEFB 189                        ;
                        DEFB 255,0,0,0,0,0,0            ; Horizontal guardian 3 (unused)
                        DEFB 0,0,0,0,0,0,0              ; Horizontal guardian 4 (unused)
                        DEFB 255                        ; Terminator

; The next two bytes are not used.

                        DEFB 0,0                        ; Unused

; The next byte indicates that there are no vertical guardians in this cavern.

                        DEFB 255                        ; Terminator

; The next two bytes are unused.

                        DEFB 0,0                        ; Unused

; The next 32 bytes define the plinth graphic that appears on the Game Over screen.

PlinthGraphicData       dg ################
                        dg -###--#--#--###-
                        dg #---#-#--#-#---#
                        dg #-#-#-#--#-#-#-#
                        dg -#--#-#--#-#--#-
                        dg ---#--#--#--#---
                        dg --#---#--#---#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--
                        dg --#-#-#--#-#-#--

; The next 256 bytes define the guardian graphics.

                        dg ----##----------
                        dg ---####---------
                        dg ---##-##--------
                        dg ---####-##------
                        dg --###--#--------
                        dg --##--#---------
                        dg --###-#---------
                        dg --####-#--------
                        dg -##-##-#--------
                        dg -##-#--#--------
                        dg -##-#--#--------
                        dg -##----#--------
                        dg -###---#--------
                        dg #-#####---------
                        dg ----#-----------
                        dg ---####---------

                        dg ------##--------
                        dg -----####-------
                        dg -----##-##------
                        dg -----####-##----
                        dg ----###--#------
                        dg ----##--#-------
                        dg ----#####-------
                        dg ----##-###------
                        dg ---##-##-#------
                        dg ---##-##-#------
                        dg ---#-##--#------
                        dg ---##----#------
                        dg ---###---#------
                        dg --#-#####-------
                        dg -----#-#-#------
                        dg ----#####-------

                        dg --------##------
                        dg -------####-----
                        dg -------##-##----
                        dg -------####-##--
                        dg ------###--#----
                        dg ------##--#-----
                        dg ------###-#-----
                        dg ------####-#----
                        dg -----##-##-#----
                        dg -----##-#--#----
                        dg -----##-#--#----
                        dg -----##----#----
                        dg -----###---#----
                        dg ----#-#####-#---
                        dg ------#--#-#----
                        dg -----######-----

                        dg ----------##----
                        dg ---------####---
                        dg ---------##-##--
                        dg ---------####-##
                        dg --------###--#--
                        dg --------##--#---
                        dg --------###-#---
                        dg --------####-#--
                        dg -------##-##-#--
                        dg -------##--#-#--
                        dg -------##--#-#--
                        dg -------##----#--
                        dg -------###---#--
                        dg ------#-#####---
                        dg ---------#-#-#--
                        dg --------#####---

                        dg ----##----------
                        dg ---####---------
                        dg --##-##---------
                        dg ##-####---------
                        dg --#--###--------
                        dg ---#--##--------
                        dg ---#-###--------
                        dg --#-####--------
                        dg --#-##-##-------
                        dg --#-#--##-------
                        dg --#-#--##-------
                        dg --#----##-------
                        dg --#---###-------
                        dg ---#####-#------
                        dg --#-#-#---------
                        dg ---#####--------

                        dg ------##--------
                        dg -----####-------
                        dg ----##-##-------
                        dg --##-####-------
                        dg ----#--###------
                        dg -----#--##------
                        dg -----#-###------
                        dg ----#-####------
                        dg ----#-##-##-----
                        dg ----#--#-##-----
                        dg ----#--#-##-----
                        dg ----#----##-----
                        dg ----#---###-----
                        dg ---#-#####-#----
                        dg ----#-#--#------
                        dg -----######-----

                        dg --------##------
                        dg -------####-----
                        dg ------##-##-----
                        dg ----##-####-----
                        dg ------#--###----
                        dg -------#--##----
                        dg -------#####----
                        dg ------###-##----
                        dg ------#-##-##---
                        dg ------#-##-##---
                        dg ------#--##-#---
                        dg ------#----##---
                        dg ------#---###---
                        dg -------#####-#--
                        dg ------#-#-#-----
                        dg -------#####----

                        dg ----------##----
                        dg ---------####---
                        dg --------##-##---
                        dg ------##-####---
                        dg --------#--###--
                        dg ---------#--##--
                        dg ---------#-###--
                        dg --------#-####--
                        dg --------#-##-##-
                        dg --------#--#-##-
                        dg --------#--#-##-
                        dg --------#----##-
                        dg --------#---###-
                        dg ---------#####-#
                        dg -----------#----
                        dg ---------####---

; ---------------------------------------------------------------;
;                                                                ;
; The Menagerie (teleport: 26)                                   ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

TheMenagerieData        dh "0D0000000000000000004300000000000000030000000000000000430000000D"
                        dh "0D0000000000000000000000000000000000430000000000000000000000000D"
                        dh "0D0000000000000000000000000000000000000000000000000000000000000D"
                        dh "0D0000000000000000000000000000000000000000000000000000000000000D"
                        dh "0D0000000000000000000000000000000000000000000000000000000000000D"
                        dh "0D4545454505050505050505050505050505050505050505050505050505050D"
                        dh "0D0000000000000000000000000000000000000000000000000000000000000D"
                        dh "0D4545454545450000000000000000000000000000000000000000454545450D"
                        dh "0D0300000000000000000000000000000000000000000000000000000000000D"
                        dh "0D0300000000020202020202000000000000000000000000000000000000000D"
                        dh "0D0300000000000000000000000000000000000000000000004545454545450D"
                        dh "0D4300000000000000000000000045454545450000000000000000000000000D"
                        dh "0D0000000045454545454500000000000000000000000000000000000000000D"
                        dh "0D0000000000000000000000000000000000000000454545454545454545450D"
                        dh "0D0000000000000000000000000000000000000000000000000000000000000D"
                        dh "0D4545454545454545454545454545454545454545454545454545454545450D"

; The next 32 bytes specify the cavern name.

                        DEFM "          The Menagerie         " ;  Cavern name.

; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.

; Background
                        db $00                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $45                                ; E
                        dg ########
                        dg ########
                        dg -##--##-
                        dg #--##--#
                        dg -##--##-
                        dg #--##--#
                        dg ########
                        dg --------

; Crumbling floor
                        db $05                                ; .
                        dg ########
                        dg ########
                        dg -##--##-
                        dg #--##--#
                        dg -#----#-
                        dg ---##---
                        dg ###-#-#-
                        dg --------

; Wall
                        db $0D                                ; .
                        dg #------#
                        dg ##----##
                        dg #-#--#-#
                        dg #--##--#
                        dg #--##--#
                        dg #-#--#-#
                        dg ##----##
                        dg #------#

; Conveyor
                        db $02                                ; .
                        dg ####----
                        dg #-#-#-#-
                        dg ####----
                        dg -##--##-
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $06                                ; .
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $43                                ; C
                        dg ---#----
                        dg ##-#-##-
                        dg --###---
                        dg ##-#-##-
                        dg --###---
                        dg -#---#--
                        dg ##---##-
                        dg --#-#---

; Extra
                        db $03                                ; .
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.

                        DEFB 208                        ; Pixel y-coordinate * 2
                        DEFB 0                          ; Animation frame.
                        DEFB 0                          ; Direction and movement flags: facing right.
                        DEFB 0                          ; Airborne status indicator.
                        DEFW 23970                      ; Location in the attribute buffer at 23552: (13,2).
                        DEFB 0                          ; Jumping animation counter.

; The next four bytes specify the direction, location and length of the conveyor.

                        DEFB 0                          ; Direction (left)..
                        DEFW 30758                      ; Location in the screen buffer at 28672: (9,6).
                        DEFB 6                          ; Length.

; The next byte specifies the border colour.

                        DEFB 2                          ; Border colour.

; The next byte is copied but is not used.

                        DEFB 0                          ; Unused.

; The next 25 bytes specify the location and initial colour of the items in the cavern.

                        DEFB 3                          ; Item 1 at (0,6).
                        DEFW 23558                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 4                          ; Item 2 at (0,15).
                        DEFW 23567                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 5                          ; Item 3 at (0,23).
                        DEFW 23575                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 6                          ; Item 4 at (6,30).
                        DEFW 23774                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 3                          ; Item 5 at (6,21).
                        DEFW 23765                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 255                        ; Terminator.

; Portal

                        db $0E                                ; .
                        dg ################
                        dg -#---#---#---#--
                        dg #--##--##--##--#
                        dg --#---#---#---#-
                        dg --#---#---#---#-
                        dg #--##--##--##--#
                        dg -#---#---#---#--
                        dg -#---#---#---#--
                        dg #--##--##--##--#
                        dg --#---#---#---#-
                        dg --#---#---#---#-
                        dg #--##--##--##--#
                        dg -#---#---#---#--
                        dg -#---#---#---#--
                        dg #--##--##--##--#
                        dg ################

; Location
                        dw $5D7D,$687D

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--


; The next byte specifies the initial air supply in the cavern.

                        DEFB 63                         ; Air.

; The next byte is copied to 32957 and initialises the game clock.

                        DEFB 128                        ; Game clock.

; The next 28 bytes are copied to 32958 and define the horizontal guardians.

                        DEFB 68                         ; Horizontal guardian 1: y=13, initial x=19, 1<=x<=19, speed=normal.
                        DEFW 23987                      ;
                        DEFB 104                        ;
                        DEFB 7                          ;
                        DEFB 161                        ;
                        DEFB 179                        ;
                        DEFB 67                         ; Horizontal guardian 2: y=3, initial x=16, 1<=x<=16, speed=normal.
                        DEFW 23664                      ;
                        DEFB 96                         ;
                        DEFB 7                          ;
                        DEFB 97                         ;
                        DEFB 112                        ;
                        DEFB 66                         ; Horizontal guardian 3: y=3, initial x=18, 18<=x<=29, speed=normal.
                        DEFW 23666                      ;
                        DEFB 96                         ;
                        DEFB 0                          ;
                        DEFB 114                        ;
                        DEFB 125                        ;
                        DEFB 255,0,0,0,0,0,0            ; Horizontal guardian 4 (unused).
                        DEFB 255                        ; Terminator.

; The next two bytes are copied but are not used.

                        DEFB 0,0                        ; Unused.

; The next byte indicates that there are no vertical guardians in this cavern.

                        DEFB 255                        ; Terminator.

; The next two bytes are unused.

                        DEFB 0,0                        ; Unused.

; Boot graphic data

BootGraphicData         dg --#-#-#-##------
                        dg --##-#-#-#------
                        dg --########------
                        dg ----#--#--------
                        dg ----#--#--------
                        dg ---######-------
                        dg ---#----#-------
                        dg ---#----#-------
                        dg ---#---##-------
                        dg --#---#--#------
                        dg --#-----#-###---
                        dg -#-##--#--#--#--
                        dg -#---#---#----#-
                        dg -#---#--------#-
                        dg -#---#--------#-
                        dg ################

; The next 256 bytes define the guardian graphics.

                        dg ------##--------
                        dg -----##-#-------
                        dg -----#####------
                        dg ------##--------
                        dg -------##-------
                        dg --------##------
                        dg #-#####-##------
                        dg ###---###-------
                        dg -#-----#--------
                        dg #-#-#-##--------
                        dg -#######--------
                        dg --#####---------
                        dg ----#-----------
                        dg ----#-----------
                        dg ----#-----------
                        dg ---#-#----------

                        dg --------##------
                        dg -------##-#-----
                        dg -------#####----
                        dg --------##------
                        dg ---------##-----
                        dg ----------##----
                        dg --#-#####-##----
                        dg --###---###-----
                        dg ---##---##------
                        dg --##----##------
                        dg ---#-#-###------
                        dg ----#-#-#-------
                        dg ---#-#-#--------
                        dg ------#---------
                        dg -----#-#--------
                        dg ----------------

                        dg ----------##----
                        dg ---------##-#---
                        dg ---------#####--
                        dg ----------##----
                        dg -----------##---
                        dg ------------##--
                        dg ----#-#####-##--
                        dg ----###---###---
                        dg -----#-----#----
                        dg ----#-#-#-##----
                        dg -----#######----
                        dg ------#####-----
                        dg --------#-------
                        dg -------#-#------
                        dg ----------------
                        dg ----------------

                        dg ------------##--
                        dg -----------##-#-
                        dg -----------#####
                        dg --------#-#-##--
                        dg -------#-#-#-##-
                        dg --------#-#-#-##
                        dg ------##-#-##-##
                        dg ------###----##-
                        dg -------#----##--
                        dg ------########--
                        dg -------#######--
                        dg --------#####---
                        dg ----------#-----
                        dg ----------#-----
                        dg ---------#-#----
                        dg ----------------

                        dg --##------------
                        dg -#-##-----------
                        dg #####-----------
                        dg --##-#-#--------
                        dg -##-#-#-#-------
                        dg ##-#-#-#--------
                        dg ##-##-#-##------
                        dg -##----###------
                        dg --##----#-------
                        dg --########------
                        dg --#######-------
                        dg ---#####--------
                        dg -----#----------
                        dg -----#----------
                        dg ----#-#---------
                        dg ----------------

                        dg ----##----------
                        dg ---#-##---------
                        dg --#####---------
                        dg ----##----------
                        dg ---##-----------
                        dg --##------------
                        dg --##-#####-#----
                        dg ---###---###----
                        dg ----#-----#-----
                        dg ----##-#-#-#----
                        dg ----#######-----
                        dg -----#####------
                        dg -------#--------
                        dg ------#-#-------
                        dg ----------------
                        dg ----------------

                        dg ------##--------
                        dg -----#-##-------
                        dg ----#####-------
                        dg ------##--------
                        dg -----##---------
                        dg ----##----------
                        dg ----##-#####-#--
                        dg -----###---###--
                        dg ------##---##---
                        dg ------##----##--
                        dg ------###-#-#---
                        dg -------#-#-#----
                        dg --------#-#-#---
                        dg ---------#------
                        dg --------#-#-----
                        dg ----------------

                        dg --------##------
                        dg -------#-##-----
                        dg ------#####-----
                        dg --------##------
                        dg -------##-------
                        dg ------##--------
                        dg ------##-#####-#
                        dg -------###---###
                        dg --------#-----#-
                        dg --------##-#-#-#
                        dg --------#######-
                        dg ---------#####--
                        dg -----------#----
                        dg -----------#----
                        dg -----------#----
                        dg ----------#-#---

; ---------------------------------------------------------------;
;                                                                ;
; Abandoned Uranium Workings (teleport: 126)                     ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

AbandonedUraniumWorkingsData equ *

                        dh "2900000000000005000000000000292929292929292929292929292929292929"
                        dh "2900000000000000000000000000000000000000000000000000000000000029"
                        dh "2900000000000000000000000000000000000000000000000000000000000029"
                        dh "2900000000000000000000000000000000000046464646464600000000000029"
                        dh "2900000000000000000000000000000000000000000000000000004646464629"
                        dh "2946000000000046000000000000000000460000000000000000000000000029"
                        dh "2900000000000000000000004646000000000000004646460000000000000029"
                        dh "2906060600000000000000000000000000000000000000000000000000000029"
                        dh "2900000000000046460000000000000000000000000000000000464646000029"
                        dh "2900000000000000000000000000000000004646460000000000000000000029"
                        dh "2903030300000000000000000000000000000000000000000000000000004629"
                        dh "2900000000000000000000004646460000000000000046464600000000000029"
                        dh "2900000000004646000000000000000000000000000000050000000046464629"
                        dh "2900000000000000000000000000000000004646000000000000000000000029"
                        dh "2900000000000000000000000000000000000000000000000000000000000029"
                        dh "2946464646464646464646464646464646464646464646464646464646464629"

; The next 32 bytes specify the cavern name.

                        DEFM "   Abandoned Uranium Workings   " ; Cavern name.

; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.

; Background
                        db $00                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $46                                ; F
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $06                                ; .
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $29                                ; )
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $03                                ; .
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg #--##--#
                        dg ########
                        dg --------

; Nasty 1
                        db $04                                ; .
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $05                                ; .
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg -#-#-#--
                        dg --###---
                        dg ##-#-##-
                        dg --###---
                        dg -#-#-#--

; Extra
                        db $00                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.

                        DEFB 208                        ; Pixel y-coordinate * 2.
                        DEFB 0                          ; Animation frame.
                        DEFB 1                          ; Direction and movement flags: facing left.
                        DEFB 0                          ; Airborne status indicator.
                        DEFW 23997                      ; Location in the attribute buffer at 23552: (13,29).
                        DEFB 0                          ; Jumping animation counter.

; The next four bytes specify the direction, location and length of the conveyor.

                        DEFB 1                          ; Direction (right).
                        DEFW 30785                      ; Location in the screen buffer at 28672: (10,1).
                        DEFB 3                          ; Length.

; The next byte specifies the border colour.

                        DEFB 2                          ; Border colour

; The next byte is copied to 32884, but is not used.

                        DEFB 0                          ; Unused

; The next 25 bytes specify the location and initial colour of the items in the cavern.

                        DEFB 3                          ; Item 1 at (0,1)
                        DEFW 23553                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 4                          ; Item 2 at (1,12)
                        DEFW 23596                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 5                          ; Item 3 at (1,25)
                        DEFW 23609                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 6                          ; Item 4 at (6,16)
                        DEFW 23760                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 3                          ; Item 5 at (6,30)
                        DEFW 23774                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 255                        ; Terminator

; Portal

                        db $0E                                ; .
                        dg --#---#---#---#-
                        dg ---#---#---#---#
                        dg #---#---#---#---
                        dg -#---#---#---#--
                        dg --#---#---#---#-
                        dg ---#---#---#---#
                        dg #---#---#---#---
                        dg -#---#---#---#--
                        dg --#---#---#---#-
                        dg ---#---#---#---#
                        dg #---#---#---#---
                        dg -#---#---#---#--
                        dg --#---#---#---#-
                        dg ---#---#---#---#
                        dg #---#---#---#---
                        dg -#---#---#---#--

; Location
                        dw $5C3D,$603D

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--


; The next byte specifies the initial air supply in the cavern.

                        DEFB 63                         ; Air

; The next byte initialises the game clock.

                        DEFB 128                        ; Game clock

; The next 28 bytes define the horizontal guardians.

                        DEFB 66                         ; Horizontal guardian 1: y=13, initial x=1, 1<=x<=10, speed=normal
                        DEFW 23969                      ;
                        DEFB 104                        ;
                        DEFB 0                          ;
                        DEFB 161                        ;
                        DEFB 170                        ;
                        DEFB 68                         ; Horizontal guardian 2: y=13, initial x=7, 6<=x<=15, speed=normal
                        DEFW 23975                      ;
                        DEFB 104                        ;
                        DEFB 0                          ;
                        DEFB 166                        ;
                        DEFB 175                        ;
                        DEFB 255,0,0,0,0,0,0            ; Horizontal guardian 3 (unused)
                        DEFB 0,0,0,0,0,0,0              ; Horizontal guardian 4 (unused)
                        DEFB 255                        ; Terminator

; The next two bytes are not used.

                        DEFB 0,0                        ; Unused

; The next 28 bytes define the vertical guardians.

                        DEFB 255,0,0,0,0,0,0            ; Vertical guardian 1 (unused)
                        DEFB 0,0,0,0,0,0,0              ; Vertical guardian 2 (unused)
                        DEFB 0,0,0,0,0,0,0              ; Vertical guardian 3 (unused)
                        DEFB 0,0,0,0,0,0,0              ; Vertical guardian 4 (unused)

; The next 7 bytes are unused.

                        DEFB 0,0,0,0,0,0,0              ; Unused

; The next 256 bytes define the guardian graphics.

                        dg -----###--------
                        dg ----#-###-------
                        dg ---#--####------
                        dg ---#--####------
                        dg ---#--####------
                        dg ----#-###-------
                        dg -----###--------
                        dg -------#--------
                        dg -----###--------
                        dg -----#-#--------
                        dg -----###--------
                        dg -----####-------
                        dg -#--#####-------
                        dg -#-#######------
                        dg #######-##------
                        dg --####---#------

                        dg -------###------
                        dg ------#-###-----
                        dg -----#-###-#----
                        dg -----#-###-#----
                        dg -----#-###-#----
                        dg ------#-###-----
                        dg -------###------
                        dg ---------#------
                        dg -------###------
                        dg -------#-#------
                        dg -------###------
                        dg -------####-----
                        dg --#---#####-----
                        dg --#-########----
                        dg -########-##----
                        dg ---#####---#----

                        dg ---------###----
                        dg --------###-#---
                        dg -------####--#--
                        dg -------####--#--
                        dg -------####--#--
                        dg --------###-#---
                        dg ---------###----
                        dg -----------#----
                        dg ---------###----
                        dg ---------#-#----
                        dg ---------###----
                        dg --------#####---
                        dg --#----######---
                        dg --#--#########--
                        dg -##########-##--
                        dg ----######---#--

                        dg -----------###--
                        dg ----------##-##-
                        dg ---------##---##
                        dg ---------##---##
                        dg ---------##---##
                        dg ----------##-##-
                        dg -----------###--
                        dg -------------#--
                        dg -----------###--
                        dg -----------#-#--
                        dg -----------###--
                        dg -----------####-
                        dg -----#----#####-
                        dg -----#--########
                        dg ----#########-##
                        dg ------######---#

                        dg --###-----------
                        dg -##-##----------
                        dg ##---##---------
                        dg ##---##---------
                        dg ##---##---------
                        dg -##-##----------
                        dg --###-----------
                        dg --#-------------
                        dg --###-----------
                        dg --#-#-----------
                        dg --###-----------
                        dg -####-----------
                        dg -#####----#-----
                        dg ########--#-----
                        dg ##-#########----
                        dg #---######------

                        dg ----###---------
                        dg ---#-###--------
                        dg --#--####-------
                        dg --#--####-------
                        dg --#--####-------
                        dg ---#-###--------
                        dg ----###---------
                        dg ----#-----------
                        dg ----###---------
                        dg ----#-#---------
                        dg ----###---------
                        dg ---#####--------
                        dg ---######----#--
                        dg --#########--#--
                        dg --##-##########-
                        dg --#---######----

                        dg ------###-------
                        dg -----###-#------
                        dg ----#-###-#-----
                        dg ----#-###-#-----
                        dg ----#-###-#-----
                        dg -----###-#------
                        dg ------###-------
                        dg ------#---------
                        dg ------###-------
                        dg ------#-#-------
                        dg ------###-------
                        dg -----####-------
                        dg -----#####---#--
                        dg ----########-#--
                        dg ----##-########-
                        dg ----#---#####---

                        dg --------###-----
                        dg -------###-#----
                        dg ------####--#---
                        dg ------####--#---
                        dg ------####--#---
                        dg -------###-#----
                        dg --------###-----
                        dg --------#-------
                        dg --------###-----
                        dg --------#-#-----
                        dg --------###-----
                        dg -------####-----
                        dg -------#####--#-
                        dg ------#######-#-
                        dg ------##-#######
                        dg ------#---####--


; ---------------------------------------------------------------;
;                                                                ;
; Eugene's Lair (teleport: 36)                                   ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

EugenesLairData                   DH "2E1010101010101010101010101010101010101013101010101010101010102E"
                                  DH "2E1010101010101010101010101010101010101010101010101010101010102E"
                                  DH "2E1010101010101010101010101010101010101010101010101010101010102E"
                                  DH "2E1010101010101010101010101010101010101010101010101010101010102E"
                                  DH "2E1010101010101010101010101010101010101010101010161010101010102E"
                                  DH "2E1515151515151515151515151510101010141414141515151515151010102E"
                                  DH "2E1010101010101010101010101010101010101010101010101010101015152E"
                                  DH "2E1010101010101010101010101010101010101010161010101010101010102E"
                                  DH "2E1010101010101010101010101010101010565656565656565656561010102E"
                                  DH "2E1010101515151515151515151510101010101010101010101010101010102E"
                                  DH "2E1010101010101010101010101010101010101010101010101010101010102E"
                                  DH "2E1414151515151515151515151510101010151515151515151010101010152E"
                                  DH "2E101010101010102E101010101010101010101010101010101010101010102E"
                                  DH "2E151510101010102E10101010102E10102E101010101010101010101010102E"
                                  DH "2E101010101610102E10101010102E10102E2E2E2E2E2E2E161610101010102E"
                                  DH "2E151515151515152E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E151515151515152E"

; The next 32 bytes specify the cavern name.

                        DEFM "         Eugene's Lair          " ; Cavern name.

; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.
; Background
                        db $10
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $15
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $14
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $2E
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $56
                        dg ######--
                        dg -##--##-
                        dg ######--
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $16
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $13
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.

                        DEFB 48                         ; Pixel y-coordinate * 2.
                        DEFB 0                          ; Animation frame.
                        DEFB 0                          ; Direction and movement flags: facing right.
                        DEFB 0                          ; Airborne status indicator.
                        DEFW 23649                      ; Location in the attribute buffer at 23552: (3,1).
                        DEFB 0                          ; Jumping animation counter.

; The next four bytes specify the direction, location and length of the conveyor.

                        DEFB 0                          ; Direction (left).
                        DEFW 30738                      ; Location in the screen buffer at 28672: (8,18).
                        DEFB 10                         ; Length.

; The next byte specifies the border colour.

                        DEFB 1                          ; Border colour.

; The next byte is copied to 32884, but is not used.

                        DEFB 0                          ; Unused.

; The next 25 bytes specify the location and initial colour of the items in the cavern.

                        DEFB 19                         ; Item 1 at (1,30).
                        DEFW 23614                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 20                         ; Item 2 at (6,10).
                        DEFW 23754                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 21                         ; Item 3 at (7,29)
                        DEFW 23805                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 22                         ; Item 4 at (12,7)
                        DEFW 23943                      ;
                        DEFB 104                        ;
                        DEFB 255                        ;
                        DEFB 19                         ; Item 5 at (12,9)
                        DEFW 23945                      ;
                        DEFB 104                        ;
                        DEFB 255                        ;
                        DEFB 255                        ; Terminator.

; The next 37 bytes define the portal graphic and its location.

                        db $57                                ; W
                        dg ################
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg #-#-#-#-#-#-#-#-
                        dg ################

; Location
                        dw $5DAF,$68AF

; Item graphic

                        dg ---#####
                        dg --#---##
                        dg -#---###
                        dg ########
                        dg #---####
                        dg #---###-
                        dg #---##--
                        dg #####---


; The next byte specifies the initial air supply in the cavern.

                        DEFB 63                         ; Air.

; The next byte initialises the game clock.

                        DEFB 128                        ; Game clock.

; The next 28 bytes define the horizontal guardians.

                        DEFB 22                         ; Horizontal guardian 1: y=3, initial x=12, 1<=x<=12, speed=normal.
                        DEFW 23660                      ;
                        DEFB 96                         ;
                        DEFB 7                          ;
                        DEFB 97                         ;
                        DEFB 108                        ;
                        DEFB 16                         ; Horizontal guardian 2: y=7, initial x=4, 4<=x<=12, speed=normal.
                        DEFW 23780                      ;
                        DEFB 96                         ;
                        DEFB 0                          ;
                        DEFB 228                        ;
                        DEFB 236                        ;
                        DEFB 255,0,0,0,0,0,0            ; Horizontal guardian 3 (unused).
                        DEFB 0,0,0,0,0,0,0              ; Horizontal guardian 4 (unused)
                        DEFB 255                        ; Terminator

; The next two bytes specify Eugene's initial direction and pixel y-coordinate.

                        DEFB 0                          ; Initial direction (down)
                        DEFB 0                          ; Initial pixel y-coordinate

; The next three bytes are unused.

                        DEFB 0,0,0                      ; Unused.

; The next 32 bytes define the Eugene graphic.

                        dg ------####------
                        dg ----########----
                        dg ---##########---
                        dg ---##########---
                        dg --##---##---##--
                        dg ----###--###----
                        dg -##-########-##-
                        dg #-#-###--###-#-#
                        dg #-##---##---##-#
                        dg #--##########--#
                        dg #--##-####-##--#
                        dg #---##----##---#
                        dg -#---######---#-
                        dg ------#--#------
                        dg ------#--#------
                        dg ----###--###----

; The next 256 bytesdefine the guardian graphics.

                        dg ##--------------
                        dg ##--------------
                        dg ##--------------
                        dg ##--------------
                        dg ##--------------
                        dg ##--------------
                        dg ##--------------
                        dg ##-#######------
                        dg ##-#######------
                        dg ##########------
                        dg ---#######------
                        dg ----#####-------
                        dg -###-####-------
                        dg ########--------
                        dg ##-#####--------
                        dg ##-#####--------

                        dg --##------------
                        dg --##------------
                        dg --##------------
                        dg --##------------
                        dg --##------#-----
                        dg --##----##------
                        dg --##--##--------
                        dg --##-#----------
                        dg --##-#######----
                        dg --##########----
                        dg -----#######----
                        dg ------#####-----
                        dg ---###-####-----
                        dg --########------
                        dg --##-#####------
                        dg --##-#####------

                        dg ----##----------
                        dg ----##----------
                        dg ----##----#-----
                        dg ----##---#------
                        dg ----##---#------
                        dg ----##--#-------
                        dg ----##--#-------
                        dg ----##-#--------
                        dg ----##-#######--
                        dg ----##########--
                        dg -------#######--
                        dg --------#####---
                        dg -----###-####---
                        dg ----########----
                        dg ----##-#####----
                        dg ----##-#####----

                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##------#-
                        dg ------##----##--
                        dg ------##--##----
                        dg ------##-#------
                        dg ------##-#######
                        dg ------##########
                        dg ---------#######
                        dg ----------#####-
                        dg -------###-####-
                        dg ------########--
                        dg ------##-#####--
                        dg ------##-#####--

                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg -#------##------
                        dg --##----##------
                        dg ----##--##------
                        dg ------#-##------
                        dg #######-##------
                        dg ##########------
                        dg #######---------
                        dg -#####----------
                        dg -####-###-------
                        dg --########------
                        dg --#####-##------
                        dg --#####-##------

                        dg ----------##----
                        dg ----------##----
                        dg -----#----##----
                        dg ------#---##----
                        dg ------#---##----
                        dg -------#--##----
                        dg -------#--##----
                        dg --------#-##----
                        dg --#######-##----
                        dg --##########----
                        dg --#######-------
                        dg ---#####--------
                        dg ---####-###-----
                        dg ----########----
                        dg ----#####-##----
                        dg ----#####-##----

                        dg ------------##--
                        dg ------------##--
                        dg ------------##--
                        dg ------------##--
                        dg -----#------##--
                        dg ------##----##--
                        dg --------##--##--
                        dg ----------#-##--
                        dg ----#######-##--
                        dg ----##########--
                        dg ----#######-----
                        dg -----#####------
                        dg -----####-###---
                        dg ------########--
                        dg ------#####-##--
                        dg ------#####-##--

                        dg --------------##
                        dg --------------##
                        dg --------------##
                        dg --------------##
                        dg --------------##
                        dg --------------##
                        dg --------------##
                        dg ------#######-##
                        dg ------#######-##
                        dg ------##########
                        dg ------#######---
                        dg -------#####----
                        dg -------####-###-
                        dg --------########
                        dg --------#####-##
                        dg --------#####-##

; ---------------------------------------------------------------;
;                                                                ;
; Processing Plant (teleport: 136)                               ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

ProcessingPlantData     dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000600000000000000000016"
                        dh "1600000000000000444444000000004444000000004444444444000000000016"
                        dh "1600004444000000000000000000000016000000000000000000000044444416"
                        dh "1600000000000000000000000000000016000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000444444444400000016"
                        dh "1644440000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000044444444444444444416444444444444444444000000000016"
                        dh "1600000000000000000000000000000016060000000000000000000000000016"
                        dh "1600004300000000000000000000000016000000000000000000000044444416"
                        dh "1600000505050500000000000000000000000000000044440000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1644444444444444444444444444444444444444444444444444444444444416"

; The next 32 bytes specify the cavern name.

                        DEFM "       Processing Plant         " ; Cavern name.

; The next 72 bytes contain the attributes and graphic data for the tiles used to build the cavern.

; Background
                        db $00                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $44                                ; D
                        dg ########
                        dg ########
                        dg #--##--#
                        dg #--##--#
                        dg ########
                        dg #--##--#
                        dg -##--##-
                        dg --------

; Crumbling floor
                        db $04                                ; .
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $16                                ; .
                        dg ########
                        dg #--##--#
                        dg ########
                        dg -##--##-
                        dg ########
                        dg #--##--#
                        dg ########
                        dg -##--##-

; Conveyor
                        db $05                                ; .
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg #--##--#
                        dg ########
                        dg --------

; Nasty 1
                        db $43                                ; C
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $06                                ; .
                        dg --####--
                        dg ---##---
                        dg #-####-#
                        dg ###--###
                        dg ###--###
                        dg #-####-#
                        dg ---##---
                        dg --####--

; Extra
                        db $00                                ; .
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; The next seven bytes specify Miner Willy's initial location and appearance in the cavern.

                        DEFB 48                         ; Pixel y-coordinate * 2.
                        DEFB 3                          ; Animation frame.
                        DEFB 1                          ; Direction and movement flags: facing left.
                        DEFB 0                          ; Airborne status indicator.
                        DEFW 23663                      ; Location in the attribute buffer at 23552: (3,15).
                        DEFB 0                          ; Jumping animation counter.

; The next four bytes specify the direction, location and length of the conveyor.

                        DEFB 0                          ; Direction (left).
                        DEFW 30883                      ; Location in the screen buffer at 28672: (13,3).
                        DEFB 4                          ; Length.

; The next byte and specifies the border colour.

                        DEFB 2                          ; Border colour.

; The next byte is not used.

                        DEFB 0                          ; Unused.

; The next 25 bytes specify the location and initial colour of the items in the cavern.

                        DEFB 3                          ; Item 1 at (6,15).
                        DEFW 23759                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 4                          ; Item 2 at (6,17).
                        DEFW 23761                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 5                          ; Item 3 at (7,30).
                        DEFW 23806                      ;
                        DEFB 96                         ;
                        DEFB 255                        ;
                        DEFB 6                          ; Item 4 at (10,1).
                        DEFW 23873                      ;
                        DEFB 104                        ;
                        DEFB 255                        ;
                        DEFB 3                          ; Item 5 at (11,13).
                        DEFW 23917                      ;
                        DEFB 104                        ;
                        DEFB 255                        ;
                        DEFB 255                        ; Terminator.

; The next 37 bytes define the portal graphic and its location.

                        db $0E                                ; .
                        dg ################
                        dg #------##------#
                        dg #-############-#
                        dg #-############-#
                        dg #-##--------##-#
                        dg #-##--------##-#
                        dg #-##--------##-#
                        dg ####--------####
                        dg ####--------####
                        dg #-##--------##-#
                        dg #-##--------##-#
                        dg #-##--------##-#
                        dg #-############-#
                        dg #-############-#
                        dg #------##------#
                        dg ################

; Location
                        dw $5C1D,$601D

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; The next byte specifies the initial air supply in the cavern.

                        DEFB 63                         ; Air.

; The next byte initialises the game clock.

                        DEFB 128                        ; Game clock.

; The next 28 bytes define the horizontal guardians.

                        DEFB 70                         ; Horizontal guardian 1: y=8, initial x=6, 6<=x<=13, speed=normal.
                        DEFW 23814                      ;
                        DEFB 104                        ;
                        DEFB 0                          ;
                        DEFB 6                          ;
                        DEFB 13                         ;
                        DEFB 67                         ; Horizontal guardian 2: y=8, initial x=14, 14<=x<=21, speed=normal.
                        DEFW 23822                      ;
                        DEFB 104                        ;
                        DEFB 1                          ;
                        DEFB 14                         ;
                        DEFB 21                         ;
                        DEFB 69                         ; Horizontal guardian 3: y=13, initial x=8, 8<=x<=20, speed=normal.
                        DEFW 23976                      ;
                        DEFB 104                        ;
                        DEFB 2                          ;
                        DEFB 168                        ;
                        DEFB 180                        ;
                        DEFB 6                          ; Horizontal guardian 4: y=13, initial x=24, 24<=x<=29, speed=normal.
                        DEFW 23992                      ;
                        DEFB 104                        ;
                        DEFB 3                          ;
                        DEFB 184                        ;
                        DEFB 189                        ;
                        DEFB 255                        ; Terminator.

; The next two bytes but are not used.

                        DEFB 0,0                        ; Unused.

; The next 28 bytes define the vertical guardians.

                        DEFB 255,0,0,0,0,0,0            ; Vertical guardian 1 (unused).
                        DEFB 0,0,0,0,0,0,0              ; Vertical guardian 2 (unused).
                        DEFB 0,0,0,0,0,0,0              ; Vertical guardian 3 (unused).
                        DEFB 0,0,0,0,0,0,0              ; Vertical guardian 4 (unused).

; The next 7 bytes are unused.

                        DEFB 0,0,0,0,0,0,0              ; Unused.

; The next 256 bytes define the guardian graphics.

                        dg ---#####--------
                        dg -#########------
                        dg -###--#####-----
                        dg ####--###-------
                        dg #######---------
                        dg #####-----------
                        dg #######---------
                        dg #########-------
                        dg -##########-----
                        dg -#########------
                        dg ---#####--------
                        dg ----#-#---------
                        dg ----#-#---------
                        dg ----#-#---------
                        dg ----#-#---------
                        dg ---#####--------

                        dg -----#####------
                        dg ---#########----
                        dg ---####--###----
                        dg --#####--####---
                        dg --###########---
                        dg --#####---------
                        dg --###########---
                        dg --###########---
                        dg ---#########----
                        dg ---#########----
                        dg -----#####------
                        dg ------#-#-------
                        dg ------#-#-------
                        dg -----#####------
                        dg ----------------
                        dg ----------------

                        dg -------#####----
                        dg -----#########--
                        dg -----###--#####-
                        dg ----####--###---
                        dg ----#######-----
                        dg ----#####-------
                        dg ----#######-----
                        dg ----#########---
                        dg -----##########-
                        dg -----#########--
                        dg -------#####----
                        dg -------#####----
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------

                        dg ---------#####--
                        dg -------###--####
                        dg -------###--###-
                        dg ------########--
                        dg ------######----
                        dg ------#####-----
                        dg ------######----
                        dg ------########--
                        dg -------########-
                        dg -------#########
                        dg ---------#####--
                        dg ----------#-#---
                        dg ----------#-#---
                        dg ---------#####--
                        dg ----------------
                        dg ----------------

                        dg --#####---------
                        dg ####--###-------
                        dg -###--###-------
                        dg --########------
                        dg ----######------
                        dg -----#####------
                        dg ----######------
                        dg --########------
                        dg -########-------
                        dg #########-------
                        dg --#####---------
                        dg ---#-#----------
                        dg ---#-#----------
                        dg --#####---------
                        dg ----------------
                        dg ----------------

                        dg ----#####-------
                        dg --#########-----
                        dg -#####--###-----
                        dg ---###--####----
                        dg -----#######----
                        dg -------#####----
                        dg -----#######----
                        dg ---#########----
                        dg -##########-----
                        dg --#########-----
                        dg ----#####-------
                        dg ----#####-------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------

                        dg ------#####-----
                        dg ----#########---
                        dg ----###--####---
                        dg ---####--#####--
                        dg ---###########--
                        dg ---------#####--
                        dg ---###########--
                        dg ---###########--
                        dg ----#########---
                        dg ----#########---
                        dg ------#####-----
                        dg -------#-#------
                        dg -------#-#------
                        dg ------#####-----
                        dg ----------------
                        dg ----------------

                        dg --------#####---
                        dg ------#########-
                        dg -----#####--###-
                        dg -------###--####
                        dg ---------#######
                        dg -----------#####
                        dg ---------#######
                        dg -------#########
                        dg -----##########-
                        dg ------#########-
                        dg --------#####---
                        dg ---------#-#----
                        dg ---------#-#----
                        dg ---------#-#----
                        dg ---------#-#----
                        dg --------#####---

; ---------------------------------------------------------------;
;                                                                ;
; The Vat (teleport: 236)                                        ;
;                                                                ;
; ---------------------------------------------------------------;

                                   ORG $C800

; The first 512 bytes are the attributes that define the layout of the cavern.

TheVatData                         DH "4D000000000000000000000000004D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D"
                                   DH "4D0000000000000000000000000000000000000000000000000000000000004D"
                                   DH "4D0000000000000000000000000000000000000000000000000000000000004D"
                                   DH "4D000000000000000000000000000046464D020202020202020202020202004D"
                                   DH "4D000000000000000000000000000000004D020202020202020202020202024D"
                                   DH "4D000000000000040404040400004646464D020202020202020202021602024D"
                                   DH "4D464646000000000000000000000000004D020200020202020202020202024D"
                                   DH "4D000000000000000000000000000000004D020202020202020202000202024D"
                                   DH "4D460000000000000000000000000000004D020202020216020202020202024D"
                                   DH "4D000000000000000000000000004646464D020202020202020202020202024D"
                                   DH "4D464646464646464646464600000000004D020002020202020202021602024D"
                                   DH "4D000000000000000000000000000000004D020202020202020202020202004D"
                                   DH "4D000000000000000000000000004D4D4D4D020202020216020202020202024D"
                                   DH "4D000000000000000046464600004D000000000000000000000000000000004D"
                                   DH "4D000000000000000000000000004D000000000000000000000000000000004D"
                                   DH "4D464646464646464646464646464D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D"
; Cavern name

                        db "            The Vat             "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $46
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $02
                        dg ########
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-

; Wall
                        db $4D
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $04
                        dg ####-#--
                        dg -##--##-
                        dg ####-#--
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $15
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $16
                        dg #-#--#-#
                        dg -#----#-
                        dg --####--
                        dg ##-##-##
                        dg --####--
                        dg -######-
                        dg #-#--#-#
                        dg --#--#--

; Extra
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DA2

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $70A7

; Length.
                        db $05

; Border colour
                        db $04

; Unused?
                        db $00

; Item data

                        db $13
                        dw $5C7E
                        db $60,$FF

                        db $14
                        dw $5CD4
                        db $60,$FF

                        db $15
                        dw $5CFB
                        db $60,$FF

                        db $16
                        dw $5D53
                        db $68,$FF

                        db $13
                        dw $5D7E
                        db $68,$FF
; Terminator
                        db $FF


; Portal

                        db $0B
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg ################
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg #------##------#
                        dg ################

; Location
                        dw $5DAF,$68AF

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $45
                        dw $5C2F
                        db $60,$00,$2F,$3D

                        db $43
                        dw $5D0A
                        db $68,$07,$02,$0A

                        db $06
                        dw $5DB1
                        db $68,$00,$B1,$BD

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ---##-----------
                        dg ---###----------
                        dg ----#-#-#-------
                        dg ----#####-------
                        dg ----##----------
                        dg ---###----------
                        dg ---####---------
                        dg ---###-#--------
                        dg --####----------
                        dg --#####---------
                        dg --#####---------
                        dg -##-###---------
                        dg -#---#----------
                        dg -#----#---------
                        dg #------#--------
                        dg ----------------

                        dg ----------------
                        dg ----------------
                        dg -----##---------
                        dg -----###--------
                        dg ------#-#-#-----
                        dg ------#####-----
                        dg ------###-------
                        dg -----###--------
                        dg -----####-------
                        dg -----###-#------
                        dg ----####--------
                        dg ----#####-------
                        dg ----#####-------
                        dg ---##-###-------
                        dg --##--##--------
                        dg -#------##------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg -------##-------
                        dg -------###------
                        dg --------#-#-#---
                        dg --------#####---
                        dg --------###-----
                        dg -------###------
                        dg -------####-----
                        dg -------###-#----
                        dg ------####------
                        dg ------#####-----
                        dg -----######-----
                        dg --#####-#####---

                        dg ----------------
                        dg ----------------
                        dg ---------##-----
                        dg ---------###----
                        dg ----------#-#-#-
                        dg ----------#####-
                        dg ----------###---
                        dg ---------###----
                        dg ---------####---
                        dg ---------###-#--
                        dg --------####----
                        dg --------#####---
                        dg -------######---
                        dg -------##-##----
                        dg ------##----##--
                        dg -----#----------

                        dg ----------------
                        dg ----------------
                        dg -----##---------
                        dg ----###---------
                        dg -#-#-#----------
                        dg -#####----------
                        dg ---###----------
                        dg ----###---------
                        dg ---####---------
                        dg --#-###---------
                        dg ----####--------
                        dg ---#####--------
                        dg ---######-------
                        dg ----##-##-------
                        dg --##----##------
                        dg ----------#-----

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg -------##-------
                        dg ------###-------
                        dg ---#-#-#--------
                        dg ---#####--------
                        dg -----###--------
                        dg ------###-------
                        dg -----####-------
                        dg ----#-###-------
                        dg ------####------
                        dg -----#####------
                        dg -----######-----
                        dg ---#####-#####--

                        dg ----------------
                        dg ----------------
                        dg ---------##-----
                        dg --------###-----
                        dg -----#-#-#------
                        dg -----#####------
                        dg -------###------
                        dg --------###-----
                        dg -------####-----
                        dg ------#-###-----
                        dg --------####----
                        dg -------#####----
                        dg -------#####----
                        dg -------###-##---
                        dg --------##--##--
                        dg ------##------#-

                        dg -----------##---
                        dg ----------###---
                        dg -------#-#-#----
                        dg -------#####----
                        dg ----------##----
                        dg ----------###---
                        dg ---------####---
                        dg --------#-###---
                        dg ----------####--
                        dg ---------#####--
                        dg ---------#####--
                        dg ---------###-##-
                        dg ----------#---#-
                        dg ---------#----#-
                        dg --------#------#
                        dg ----------------


; ---------------------------------------------------------------;
;                                                                ;
; Miner Willy meets the Kong Beast (teleport: 1236)              ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

MinerWillyMeetsTheKongBeastData   DH "7200050000000600000005000000000000720600720000000000000000000072"
                                  DH "7200000000000000000000000000000000720000720000000000000000000072"
                                  DH "7200000000000000000000000000004242720000000000000000000000424272"
                                  DH "7200000000000000000000000000000000720000000000000000000000000072"
                                  DH "7200000000000000000000000000000000720000000000000000000000000072"
                                  DH "7242424200000000004242424242420000724242000000000000000000000072"
                                  DH "7200000000000000000000000000000000720000004242424200000000004272"
                                  DH "7200424242000000000000000000000000720000000000000000004200000072"
                                  DH "7200000000000000424242000000000000720000000000000000000000000072"
                                  DH "7200000000000000000000000000000000724242424242000000000000000072"
                                  DH "7242000000000000000000004242420000720000000000000000004242424272"
                                  DH "7200000000000000004242000000000000720000000000000000000000000072"
                                  DH "7200000042420000000000000000000000720000000042424242420000000072"
                                  DH "7200000000000000000000444444720000724242000000000000000000000072"
                                  DH "7200000000000000000000000000720000720000000000040000000000000072"
                                  DH "7242424242424242424242424242424242424242424242424242424242424272"

; Cavern name

                        db "Miner Willy meets the Kong Beast"

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $42
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $02
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $72
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $44
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg #-#-#-#-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $04
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $05
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $06
                        dg ########
                        dg #------#
                        dg #------#
                        dg -#----#-
                        dg --####--
                        dg ---#----
                        dg -##-----
                        dg -##-----

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DA2

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                        dw $78AB

; Length.
                        db $03

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C4D
                        db $60,$FF

                        db $04
                        dw $5CCE
                        db $60,$FF

                        db $05
                        dw $5D02
                        db $68,$FF

                        db $06
                        dw $5DBD
                        db $68,$FF

                        db $FF
                        dw $FFFF
                        db $FF,$FF
; Terminator
                        db $FF


; Portal

                        db $0E
                        dg ################
                        dg #--------------#
                        dg ##------------##
                        dg #-#----------#-#
                        dg #--#--------#--#
                        dg ##--#------#--##
                        dg #-#--#----#--#-#
                        dg #--#--#--#--#--#
                        dg ##--#--##--#--##
                        dg #-#--#----#--#-#
                        dg #--#--#--#--#--#
                        dg ##--#--##--#--##
                        dg #-#--#----#--#-#
                        dg ##--#--##--#--##
                        dg #--#--#--#--#--#
                        dg ################

; Location
                        dw $5DAF,$68AF

; Item graphic

                        dg #-------
                        dg ##------
                        dg ###-##--
                        dg -###--#-
                        dg --#-#---
                        dg -#-#-#--
                        dg #---#-#-
                        dg #----###

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $44
                        dw $5DA9
                        db $68,$07,$A1,$A9

                        db $C3
                        dw $5D6B
                        db $68,$00,$6B,$6F

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $05
                        dw $5CF2
                        db $60,$00,$F2,$F5

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ---#--####--#---
                        dg ---###-##-###---
                        dg ----########----
                        dg -----##--##-----
                        dg -----#-##-#-----
                        dg ------#--#------
                        dg -----######-----
                        dg ----########----
                        dg ---##########---
                        dg --##--####--##--
                        dg -##---####---##-
                        dg -#---##--##---#-
                        dg --#-##----##-#--
                        dg -----##--##-----
                        dg ------#--#------
                        dg ----###--###----

                        dg ----#-####-#----
                        dg ----##-##-##----
                        dg ----########----
                        dg -----##--##-----
                        dg -----#-##-#-----
                        dg ------#--#------
                        dg ------####------
                        dg ---##########---
                        dg -##############-
                        dg ###--######--###
                        dg #-----####-----#
                        dg ##---######---##
                        dg -----##--##-----
                        dg ----##----##----
                        dg ----#------#----
                        dg --###------###--

                        dg ---###----###---
                        dg -----##--##-----
                        dg ----##----##----
                        dg -##--##--##--##-
                        dg --#---####---#--
                        dg -##--######--##-
                        dg --##-######-##--
                        dg ---##########---
                        dg ----########----
                        dg -----######-----
                        dg ------#--#------
                        dg -----#-##-#-----
                        dg -----##--##-----
                        dg ----########----
                        dg ----##-##-##----
                        dg ----#-####-#----

                        dg -###--------###-
                        dg ---##------##---
                        dg ----##----##----
                        dg -----##--##-----
                        dg -##---####---##-
                        dg --#--######--#--
                        dg -##--######--##-
                        dg --##-######-##--
                        dg ---##########---
                        dg ----########----
                        dg ------#--#------
                        dg -----#-##-#-----
                        dg ---#-##--##-#---
                        dg ----########----
                        dg ----##-##-##----
                        dg ------####------

                        dg ----#-----------
                        dg -----#-#--------
                        dg ----#---#-------
                        dg --#--#-#--------
                        dg -#--#---#-------
                        dg --#----#--------
                        dg -#--##----------
                        dg --##--##--------
                        dg -#---#--#-------
                        dg -#---#--#-------
                        dg #---#----#------
                        dg #----#---#------
                        dg -#--#---#-------
                        dg -#--#---#-------
                        dg --##--##--------
                        dg ----##----------

                        dg ------#---------
                        dg ---#---#--#-----
                        dg ----#-#--#------
                        dg ---#---#--#-----
                        dg ----#-#--#------
                        dg ---#------#-----
                        dg ------##--------
                        dg ----##--##------
                        dg ---#------#-----
                        dg ---#-----##-----
                        dg --#---#-#--#----
                        dg --#--#-#---#----
                        dg ---##-----#-----
                        dg ---#------#-----
                        dg ----##--##------
                        dg ------##--------

                        dg ---------#------
                        dg ------#---#-----
                        dg -----#---#--#---
                        dg ------#---#--#--
                        dg -----#---#--#---
                        dg ------#------#--
                        dg --------##--#---
                        dg ------##--##----
                        dg -----#------#---
                        dg -----#------#---
                        dg ----#-##-#---#--
                        dg ----#---#-##-#--
                        dg -----#------#---
                        dg -----#------#---
                        dg ------##--##----
                        dg --------##------

                        dg ---------#---#--
                        dg -------#--#---#-
                        dg ------#--#---#--
                        dg -------#--#---#-
                        dg ------#--#---#--
                        dg -------#------#-
                        dg ------#---##----
                        dg --------##--##--
                        dg -------#-#----#-
                        dg -------#--#---#-
                        dg ------#----#---#
                        dg ------#---#----#
                        dg -------#---#--#-
                        dg -------#----#-#-
                        dg --------##--##--
                        dg ----------##----


; ---------------------------------------------------------------;
;                                                                ;
; Wacky Amoebatrons (teleport: 46)                               ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

; Cavern attributes

                        dh "1600001600000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1606060606000006060600000606060606060606000006060600000606000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000060616"
                        dh "1600000606000006060600000404040404040404000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000006060600000606000016"
                        dh "1606060000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000606000006060600000606060606060606000006060600000606000016"
                        dh "1600000000000000000000000000000000000000000000000000000000060616"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1606060606060606060606060606060606060606060606060606060606060616"

; Cavern name

                        db "        Wacky Amoebatrons       "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $06
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $42
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $16
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-

; Conveyor
                        db $04
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $44
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $05
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DA1

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                        dw $780C

; Length.
                        db $08

; Border colour
                        db $01

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C30
                        db $60,$FF

                        db $FF
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF
; Terminator
                        db $FF


; Portal

                        db $0E
                        dg ################
                        dg #--------------#
                        dg #------##------#
                        dg #-----#--#-----#
                        dg #----#----#----#
                        dg #---#------#---#
                        dg #--#--------#--#
                        dg #-#----##----#-#
                        dg #-#----##----#-#
                        dg #--#--------#--#
                        dg #---#------#---#
                        dg #----#----#----#
                        dg #-----#--#-----#
                        dg #------##------#
                        dg #--------------#
                        dg ################

; Location
                        dw $5C01,$6001

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $44
                        dw $5C6C
                        db $60,$00,$6C,$72

                        db $85
                        dw $5D50
                        db $68,$00,$4C,$52

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $43
                        dw $0800
                        db $05,$01,$05,$64

                        db $04
                        dw $0801
                        db $0A,$02,$05,$64

                        db $05
                        dw $0802
                        db $14,$01,$05,$64

                        db $42
                        dw $0803
                        db $19,$02,$05,$64

; Terminator
                        db $FF

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ----#-#---#-----
                        dg ---#-##--##-#---
                        dg -------#-#-#----
                        dg --###--#-##---#-
                        dg -##--#-###--###-
                        dg ------####-#----
                        dg ###########-###-
                        dg #----#######---#
                        dg -###-######--#--
                        dg ##---###########
                        dg #---#-######---#
                        dg --##--#-#-#-##--
                        dg -##--#--#-#--##-
                        dg -#--#--##-#---#-
                        dg ---#--#-#--#----
                        dg --##-##-#--##---

                        dg ----------------
                        dg -----#-#--#-----
                        dg ------##-#------
                        dg --##---#-###-#--
                        dg ---###-###--##--
                        dg ------####-#----
                        dg --#########-##--
                        dg -----#######-#--
                        dg --#########-----
                        dg -##--#########--
                        dg ----#-######--#-
                        dg --##--#-#-#-##--
                        dg --#--#--#-#--#--
                        dg ----#-###--#----
                        dg ---##-#-##-##---
                        dg --------##------

                        dg ----------------
                        dg ----------------
                        dg ------#---#-----
                        dg ----#--#-##-----
                        dg -----#-###--#---
                        dg ------####-#----
                        dg ---########-----
                        dg -----########---
                        dg ---########-----
                        dg ---#-########---
                        dg ----########----
                        dg ---#--#-#-#-#---
                        dg -----#-##-#-----
                        dg ----#-#-#-##----
                        dg --------##------
                        dg ----------------

                        dg ----------------
                        dg -----#-#--#-----
                        dg ------##-#------
                        dg --##---#-###-#--
                        dg ---###-###--##--
                        dg ------####-#----
                        dg --#########-##--
                        dg -----#######-#--
                        dg --#########-----
                        dg -##--#########--
                        dg ----#-######--#-
                        dg --##--#-#-#-##--
                        dg --#--#--#-#--#--
                        dg ----#-###--#----
                        dg ---##-#-##-##---
                        dg --------##------

                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ##########------
                        dg ----##----------
                        dg -##----##-------
                        dg ##-#--#-##------
                        dg #-##--##-#------
                        dg -##----##-------

                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg --##########----
                        dg ------##--------
                        dg ---##----##-----
                        dg --#--#--##-#----
                        dg --####--##-#----
                        dg ---##----##-----

                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg ----##########--
                        dg --------##------
                        dg -----##----##---
                        dg ----#-##--##-#--
                        dg ----##-#--#-##--
                        dg -----##----##---

                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ------##########
                        dg ----------##----
                        dg -------##----##-
                        dg ------#--#--##-#
                        dg ------####--##-#
                        dg -------##----##-


; ---------------------------------------------------------------;
;                                                                ;
; The Endorian Forest (teleport: 146)                            ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

; Cavern attributes

                                  DH "1600000000000000000000040044444416000400044444444444444444444416"
                                  DH "1600000000000000000000000000000016000000000400000000000000000016"
                                  DH "1644444444444400000000000000000016000000000000000000004444444416"
                                  DH "1600000400000000000000000000000016000000000000000000000000000016"
                                  DH "1600000000000000000000000000000016444444440000000000000000000016"
                                  DH "1600000000000000440202020202020216000000000000444444444444444416"
                                  DH "1644444444000000000000000000000016000000000000000000000000000016"
                                  DH "1600000000000000000000000000000016444444444444440202020000000016"
                                  DH "1644444444440000000000000000000016000000000000000000000000000016"
                                  DH "1604000000000000004444444444444416000000000000000000000000444416"
                                  DH "1644444444020200000000000000000016444444444444440000000000000416"
                                  DH "1600000000000000000000000000000016000000000000040202020000000016"
                                  DH "1600000000000000050505050505050505050000000000000000000000000016"
                                  DH "1644444400000000000000000000000000000000000000000000000044444416"
                                  DH "1600000000000000000000000000000000000000000000000000000000000016"
                                  DH "0505050505050505050505050505050505050505050505050505050505050505"

; Cavern name

                        db "       The Endorian Forest      "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $44
                        dg -#####--
                        dg ########
                        dg ###-####
                        dg ---####-
                        dg ----##--
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Crumbling floor
                        db $02
                        dg ######--
                        dg ########
                        dg #----###
                        dg ----##--
                        dg ----#---
                        dg ----#---
                        dg ----#---
                        dg --------

; Wall
                        db $16
                        dg -#--#-#-
                        dg -#--#-#-
                        dg -#--#-#-
                        dg -#-#--#-
                        dg -#-#-#--
                        dg -#--#-#-
                        dg --#-#-#-
                        dg --#-#-#-

; Conveyor
                        db $43
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $45
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $04
                        dg -#--#---
                        dg #-##--#-
                        dg -#-###-#
                        dg ---#--#-
                        dg -###----
                        dg #-#-###-
                        dg #-#-#--#
                        dg -#---###

; Extra
                        db $05
                        dg ########
                        dg ########
                        dg ##--#-#-
                        dg -##--#-#
                        dg #--#--#-
                        dg --#-#---
                        dg #-----#-
                        dg --------

; Pixel y-coordinate * 2.
                        db $40

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5C81

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $7013

; Length.
                        db $01

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C55
                        db $60,$FF

                        db $04
                        dw $5C2E
                        db $60,$FF

                        db $05
                        dw $5CCC
                        db $60,$FF

                        db $06
                        dw $5D12
                        db $68,$FF

                        db $03
                        dw $5C3E
                        db $60,$FF
; Terminator
                        db $FF


; Portal

                        db $1E
                        dg ################
                        dg #####---#---####
                        dg #---#---#--#---#
                        dg #-#-#-#-#--#---#
                        dg #-#-#-#-#--#-#-#
                        dg #---#-#-#----#-#
                        dg #--#----#--#---#
                        dg ##-#-#-##-###--#
                        dg ##-#-#-#-#-#-#-#
                        dg ##-#---#-#---#-#
                        dg #---#--#--###--#
                        dg #---#--#------##
                        dg #-#-#---#-#-#-##
                        dg #-#-#-#-#-#-#-##
                        dg #---#-#-#---#--#
                        dg ################

; Location
                        dw $5DAC,$68AC

; Item graphic

                        dg ----#---
                        dg ----#---
                        dg --#####-
                        dg -#-#####
                        dg -#-#####
                        dg -#---###
                        dg -##----#
                        dg --#####-

; Air supply
                        db $3F

; Game clock
                        db $F8

; Horizontal guardians

                        db $46
                        dw $5CE9
                        db $60,$00,$E9,$EE

                        db $C2
                        dw $5D4C
                        db $68,$00,$48,$4E

                        db $43
                        dw $5DA8
                        db $68,$00,$A4,$BA

                        db $05
                        dw $5CB2
                        db $60,$00,$B1,$B5

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg -###------------
                        dg -#-#------------
                        dg -#####----------
                        dg --##-#----------
                        dg --#####---------
                        dg --#####---------
                        dg ---##-----------
                        dg --####----------
                        dg -######---------
                        dg -######---------
                        dg ####-###--------
                        dg #####-##--------
                        dg --####----------
                        dg -###-##---------
                        dg -##-###---------
                        dg -###-###--------

                        dg ---###----------
                        dg ---#-#----------
                        dg ---#####--------
                        dg ----##-#--------
                        dg ----#####-------
                        dg ----#####-------
                        dg -----##---------
                        dg ----####--------
                        dg ---##-###-------
                        dg ---##-###-------
                        dg ---##-###-------
                        dg ---###-##-------
                        dg ----####--------
                        dg -----##---------
                        dg -----##---------
                        dg -----###--------

                        dg -----###--------
                        dg -----#-#--------
                        dg -----#####------
                        dg ------##-#------
                        dg ------#####-----
                        dg ------#####-----
                        dg -------##-------
                        dg ------####------
                        dg -----######-----
                        dg -----######-----
                        dg ----####-###----
                        dg ----#####-##----
                        dg ------####------
                        dg -----###-##-----
                        dg -----##-###-----
                        dg -----###-###----

                        dg -------###------
                        dg -------#-#------
                        dg -------#####----
                        dg --------##-#----
                        dg --------#####---
                        dg --------#####---
                        dg ---------##-----
                        dg --------####----
                        dg -------######---
                        dg ------########--
                        dg -----##########-
                        dg -----##-####-##-
                        dg --------#####---
                        dg -------###-##-#-
                        dg ------##----###-
                        dg ------###----#--

                        dg ------###-------
                        dg -----##-#-------
                        dg ----#####-------
                        dg ----#-##--------
                        dg ---#####--------
                        dg ---#####--------
                        dg -----##---------
                        dg ----####--------
                        dg ---######-------
                        dg --########------
                        dg -##########-----
                        dg -##-####-##-----
                        dg ---#####--------
                        dg -#-##-###-------
                        dg -###----##------
                        dg --#----###------

                        dg --------###-----
                        dg -------##-#-----
                        dg ------#####-----
                        dg ------#-##------
                        dg -----#####------
                        dg -----#####------
                        dg -------##-------
                        dg ------####------
                        dg -----######-----
                        dg -----######-----
                        dg ----###-####----
                        dg ----##-#####----
                        dg ------####------
                        dg -----##-###-----
                        dg -----###-##-----
                        dg ----###-###-----

                        dg ----------###---
                        dg ---------##-#---
                        dg --------#####---
                        dg --------#-##----
                        dg -------#####----
                        dg -------#####----
                        dg ---------##-----
                        dg --------####----
                        dg -------######---
                        dg -------###-##---
                        dg -------###-##---
                        dg -------##-###---
                        dg --------####----
                        dg ---------##-----
                        dg ---------##-----
                        dg --------###-----

                        dg ------------###-
                        dg -----------##-#-
                        dg ----------#####-
                        dg ----------#-##--
                        dg ---------#####--
                        dg ---------#####--
                        dg -----------##---
                        dg ----------####--
                        dg ---------######-
                        dg ---------######-
                        dg --------###-####
                        dg --------##-#####
                        dg ----------####--
                        dg ---------##-###-
                        dg ---------###-##-
                        dg --------###-###-

; ---------------------------------------------------------------;
;                                                                ;
; Attack of the Mutant Telephones (teleport: 246)                ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

; Cavern attributes

                                  DH "0E0E0E0E0E0E0E0000000000000000000000004200000000000000000000000E"
                                  DH "0E0000000000000000000000000000000000004600000000000000000000000E"
                                  DH "0E0000000000000000000000000000000000000000000000000000000000000E"
                                  DH "0E4141414100000000000000000000000000000000000000000000000000000E"
                                  DH "0E0000000000000000000000000000000000000000000000000000000000000E"
                                  DH "0E0000000041414141414100000000414145454545454545414100000000000E"
                                  DH "0E0000000000000000000000000000000000000000000000420000000041410E"
                                  DH "0E0000000000000000000000000000000000000000000000420000000000000E"
                                  DH "0E4141000006060000000000000000000000000000000000420000000041410E"
                                  DH "0E0000000000000000000041414141414141414100000000460000000000000E"
                                  DH "0E0000000000000000000000420000000000004200000000000000004100000E"
                                  DH "0E0000000000010101410000420000000000004600000000000000000000000E"
                                  DH "0E0000000000000000000000460000000000000000000000000000004141410E"
                                  DH "0E4141000000000000000000000000000000000000000041414100000000000E"
                                  DH "0E0000000000000000000000000000000000000000000000000000000000000E"
                                  DH "0E4141414141414141414141414141414141414141414141414141414141410E"

; Cavern name

                        db "Attack of the Mutant Telephones "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $41
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $01
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $0E
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#

; Conveyor
                        db $06
                        dg #######-
                        dg -##--##-
                        dg #######-
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $46
                        dg ---#----
                        dg ---#----
                        dg ##-#-##-
                        dg --###---
                        dg ##-#-##-
                        dg --###---
                        dg -#-#-#--
                        dg #--#--#-

; Nasty 2
                        db $42
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----

; Extra
                        db $45
                        dg ########
                        dg ########
                        dg ########
                        dg ########
                        dg #-#-#-#-
                        dg --------
                        dg --------
                        dg --------

; Pixel y-coordinate * 2.
                        db $10

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5C23

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $7805

; Length.
                        db $02

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C18
                        db $60,$FF

                        db $04
                        dw $5C3E
                        db $60,$FF

                        db $05
                        dw $5C81
                        db $60,$FF

                        db $06
                        dw $5CD3
                        db $60,$FF

                        db $03
                        dw $5DBE
                        db $68,$FF
; Terminator
                        db $FF


; Portal

                        db $56
                        dg ################
                        dg ##-##-#-#-#-#-##
                        dg ###-#-#--##-#-##
                        dg ################
                        dg #--#--------#--#
                        dg #--#--------#--#
                        dg ################
                        dg #--#--------#--#
                        dg #--#--------#--#
                        dg ################
                        dg #--#--------#--#
                        dg #--#--------#--#
                        dg ################
                        dg #--#--------#--#
                        dg #--#--------#--#
                        dg ################

; Location
                        dw $5C21,$6021

; Item graphic

                        dg --####--
                        dg -#-##-#-
                        dg #--#-#-#
                        dg ##-#-#-#
                        dg ##-#-#-#
                        dg ##-#-#-#
                        dg -#-##-#-
                        dg --####--

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $46
                        dw $5C6F
                        db $60,$00,$6F,$78

                        db $C4
                        dw $5CEE
                        db $60,$00,$EE,$F2

                        db $42
                        dw $5DAF
                        db $68,$07,$A5,$B3

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $43
                        dw $0800
                        db $0C,$02,$02,$38

                        db $04
                        dw $2001
                        db $03,$01,$20,$64

                        db $06
                        dw $3002
                        db $15,$01,$30,$64

                        db $42
                        dw $3003
                        db $1A,$FD,$04,$64

; Terminator
                        db $FF

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ----------------
                        dg ----------------
                        dg --############--
                        dg -##---####---##-
                        dg ###-#-####-#-###
                        dg ###-#------#-###
                        dg ----########----
                        dg -----######-----
                        dg ----##----##----
                        dg ----#-####-#----
                        dg ---##-####-##---
                        dg ---###----###---
                        dg --############--
                        dg --############--
                        dg --############--
                        dg --############--

                        dg --####----------
                        dg -#########------
                        dg -############---
                        dg -##---####---##-
                        dg ----#----#-#-###
                        dg ----#------#-###
                        dg ----########-###
                        dg -----######-----
                        dg ----##----##----
                        dg ----#-####-#----
                        dg ---##-####-##---
                        dg ---###----###---
                        dg --############--
                        dg --############--
                        dg --############--
                        dg --############--

                        dg ----------------
                        dg ----------------
                        dg --############--
                        dg -##---####---##-
                        dg ###-#-####-#-###
                        dg ###-#------#-###
                        dg ----########----
                        dg -----######-----
                        dg ----##----##----
                        dg ----#-####-#----
                        dg ---##-####-##---
                        dg ---###----###---
                        dg --############--
                        dg --############--
                        dg --############--
                        dg --############--

                        dg ----------####--
                        dg ------#########-
                        dg ---############-
                        dg -##---####---##-
                        dg ###-#-#----#----
                        dg ###-#------#----
                        dg ###-########----
                        dg -----######-----
                        dg ----##----##----
                        dg ----#-####-#----
                        dg ---##-####-##---
                        dg ---###----###---
                        dg --############--
                        dg --############--
                        dg --############--
                        dg --############--

                        dg ----##----------
                        dg ---#-##---------
                        dg --#-##-#--------
                        dg -#--##--#-------
                        dg #---##---#------
                        dg #---##---#------
                        dg -#--##--#-------
                        dg --#-##-#--------
                        dg ---#-##---------
                        dg ----##----------
                        dg --##-###--------
                        dg -#--##----------
                        dg -#########------
                        dg ##########------
                        dg -#------#-------
                        dg --#-###---------

                        dg ------##--------
                        dg ------##--------
                        dg -----#-##-------
                        dg -----####-------
                        dg ----#-##-#------
                        dg ----#-##-#------
                        dg -----####-------
                        dg -----#-##-------
                        dg ------##--------
                        dg ------##--------
                        dg ----###-##------
                        dg ------##--#-----
                        dg --#########-----
                        dg --##########----
                        dg ---#------#-----
                        dg -----###-#------

                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------#-------
                        dg --------#-------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg -------###-#----
                        dg -----#--##--#---
                        dg ----##########--
                        dg ----#########---
                        dg ------------#---
                        dg ------###-##----

                        dg ----------##----
                        dg ---------##-#---
                        dg --------#-##-#--
                        dg --------#-##-#--
                        dg -------#--##--#-
                        dg -------#--##--#-
                        dg --------#-##-#--
                        dg --------#-##-#--
                        dg ---------##-#---
                        dg ----------##----
                        dg --------#-###---
                        dg -------#--##--#-
                        dg ------##########
                        dg -------#########
                        dg -------#--------
                        dg --------##-###--

; ---------------------------------------------------------------;
;                                                                ;
; Return of the Alien Kong Beast (teleport: 1246)                ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

; Cavern attributes

                                  DH "6500050000000600000005000000000000650600006500000000000000000065"
                                  DH "6500000000000000000000000000000000000000000000000000000000000065"
                                  DH "6500000000000000000000000000000303000000000000000000000000000065"
                                  DH "6500000000000000000000000000000000000000000000000000000000000065"
                                  DH "6500000000000000000000000000000000000000000000000000000000000065"
                                  DH "6543434300000000000303030303650000650303030303034343000000000065"
                                  DH "6500000000000000000000000000650000650000000000000000000000004365"
                                  DH "6500000000004343000000000000650000650000000000000000000000000065"
                                  DH "6500004300000000000000000000650000650000000000000043434343434365"
                                  DH "6500000000000000000043434343650000650000000000000000000000000065"
                                  DH "6500000000004300000000000000000000654343430000000000000000000065"
                                  DH "6500000000000000000000000000000000650000000000000043430000000065"
                                  DH "6543434343434300000000000000000000650000000000040000000004000065"
                                  DH "6500000000000000000000434343650000654646464646464646464646000065"
                                  DH "6500000000000000000000000000650000650000000000000000000000000065"
                                  DH "6543434343434343434343434343656565654343434343434343434343434365"

; Cavern name

                        db " Return of the Alien Kong Beast "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $43
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $03
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $65
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $46
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg #-#-#-#-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $04
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $05
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $06
                        dg ########
                        dg #------#
                        dg #------#
                        dg -#----#-
                        dg --####--
                        dg ---#----
                        dg -##-----
                        dg -##-----

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DA2

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                        dw $78B2

; Length.
                        db $0B

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C6F
                        db $60,$FF

                        db $04
                        dw $5CF0
                        db $60,$FF

                        db $05
                        dw $5CC2
                        db $60,$FF

                        db $06
                        dw $5DBD
                        db $68,$FF

                        db $03
                        dw $5CBA
                        db $60,$FF
; Terminator
                        db $FF


; Portal

                        db $5E
                        dg ################
                        dg #--------------#
                        dg #---########---#
                        dg #---########---#
                        dg #---########---#
                        dg #---########---#
                        dg #---########---#
                        dg #---##----##---#
                        dg #---##----##---#
                        dg #---########---#
                        dg #---########---#
                        dg #---########---#
                        dg #---########---#
                        dg #---########---#
                        dg #--------------#
                        dg ################

; Location
                        dw $5DAF,$68AF

; Item graphic

                        dg #-------
                        dg ##------
                        dg ###-##--
                        dg -###--#-
                        dg --#-#---
                        dg -#-#-#--
                        dg #---#-#-
                        dg #----###

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $44
                        dw $5DA9
                        db $68,$07,$A1,$A9

                        db $C6
                        dw $5D6B
                        db $68,$00,$6B,$6F

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $05
                        dw $5CD9
                        db $60,$00,$D9,$DC

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ---#--####--#---
                        dg ---###-##-###---
                        dg ----########----
                        dg -----##--##-----
                        dg -----#-##-#-----
                        dg ------#--#------
                        dg -----######-----
                        dg ----########----
                        dg ---##########---
                        dg --##--####--##--
                        dg -##---####---##-
                        dg -#---##--##---#-
                        dg --#-##----##-#--
                        dg -----##--##-----
                        dg ------#--#------
                        dg ----###--###----

                        dg ----#-####-#----
                        dg ----##-##-##----
                        dg ----########----
                        dg -----##--##-----
                        dg -----#-##-#-----
                        dg ------#--#------
                        dg ------####------
                        dg ---##########---
                        dg -##############-
                        dg ###--######--###
                        dg #-----####-----#
                        dg ##---######---##
                        dg -----##--##-----
                        dg ----##----##----
                        dg ----#------#----
                        dg --###------###--

                        dg ---###----###---
                        dg -----##--##-----
                        dg ----##----##----
                        dg -##--##--##--##-
                        dg --#---####---#--
                        dg -##--######--##-
                        dg --##-######-##--
                        dg ---##########---
                        dg ----########----
                        dg -----######-----
                        dg ------#--#------
                        dg -----#-##-#-----
                        dg -----##--##-----
                        dg ----########----
                        dg ----##-##-##----
                        dg ----#-####-#----

                        dg -###--------###-
                        dg ---##------##---
                        dg ----##----##----
                        dg -----##--##-----
                        dg -##---####---##-
                        dg --#--######--#--
                        dg -##--######--##-
                        dg --##-######-##--
                        dg ---##########---
                        dg ----########----
                        dg ------#--#------
                        dg -----#-##-#-----
                        dg ---#-##--##-#---
                        dg ----########----
                        dg ----##-##-##----
                        dg ------####------

                        dg ----#-----------
                        dg -----#-#--------
                        dg ----#---#-------
                        dg --#--#-#--------
                        dg -#--#---#-------
                        dg --#----#--------
                        dg -#--##----------
                        dg --##--##--------
                        dg -#---#--#-------
                        dg -#---#--#-------
                        dg #---#----#------
                        dg #----#---#------
                        dg -#--#---#-------
                        dg -#--#---#-------
                        dg --##--##--------
                        dg ----##----------

                        dg ------#---------
                        dg ---#---#--#-----
                        dg ----#-#--#------
                        dg ---#---#--#-----
                        dg ----#-#--#------
                        dg ---#------#-----
                        dg ------##--------
                        dg ----##--##------
                        dg ---#------#-----
                        dg ---#-----##-----
                        dg --#---#-#--#----
                        dg --#--#-#---#----
                        dg ---##-----#-----
                        dg ---#------#-----
                        dg ----##--##------
                        dg ------##--------

                        dg ---------#------
                        dg ------#---#-----
                        dg -----#---#--#---
                        dg ------#---#--#--
                        dg -----#---#--#---
                        dg ------#------#--
                        dg --------##--#---
                        dg ------##--##----
                        dg -----#------#---
                        dg -----#------#---
                        dg ----#-##-#---#--
                        dg ----#---#-##-#--
                        dg -----#------#---
                        dg -----#------#---
                        dg ------##--##----
                        dg --------##------

                        dg ---------#---#--
                        dg -------#--#---#-
                        dg ------#--#---#--
                        dg -------#--#---#-
                        dg ------#--#---#--
                        dg -------#------#-
                        dg ------#---##----
                        dg --------##--##--
                        dg -------#-#----#-
                        dg -------#--#---#-
                        dg ------#----#---#
                        dg ------#---#----#
                        dg -------#---#--#-
                        dg -------#----#-#-
                        dg --------##--##--
                        dg ----------##----

; ---------------------------------------------------------------;
;                                                                ;
; Ore Refinary (teleport: 346)                                   ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

; Cavern attributes

                                  DH "1616161616161616161616161616161616161616161616161616161616161616"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000005050505050505050505050505050505050500000505050516"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000005050000050505050000050505050500000505050500000516"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000005050505050000050505000000050505050500000505050516"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000005050500000505050000050505050000050505050000050516"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1600000600000000000000000000000000000000000000000000000000000016"
                                  DH "1605050404040404040404040404040404040404040404040404040404050516"

; Cavern name

                        db "          Ore Refinery          "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $05
                        dg ########
                        dg ########
                        dg ---#---#
                        dg --#---#-
                        dg -#---#--
                        dg #---#---
                        dg ########
                        dg ########

; Crumbling floor
                        db $42
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $16
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-
                        dg -#-##-#-

; Conveyor
                        db $04
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $44
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $45
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $06
                        dg ########
                        dg #------#
                        dg #------#
                        dg #------#
                        dg #------#
                        dg #------#
                        dg #------#
                        dg #------#

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DBD

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                        dw $78E3

; Length.
                        db $1A

; Border colour
                        db $01

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C7A
                        db $60,$FF

                        db $04
                        dw $5CCA
                        db $60,$FF

                        db $05
                        dw $5D33
                        db $68,$FF

                        db $06
                        dw $5D3A
                        db $68,$FF

                        db $03
                        dw $5D8B
                        db $68,$FF
; Terminator
                        db $FF


; Portal

                        db $4F
                        dg ------####------
                        dg -----######-----
                        dg ----########----
                        dg ----#--##--#----
                        dg ----#--##--#----
                        dg -----######-----
                        dg -----#-##-#-----
                        dg ------#--#------
                        dg -##----##----##-
                        dg #####------#####
                        dg #######--#######
                        dg -----#-####-----
                        dg -----####-#-----
                        dg #######--#######
                        dg #####------#####
                        dg -##----------##-

; Location
                        dw $5DA1,$68A1

; Item graphic

                        dg ---##---
                        dg -##-###-
                        dg -#----#-
                        dg ##-##-##
                        dg ##--#--#
                        dg -##---#-
                        dg -######-
                        dg ---##---

; Air supply
                        db $3F

; Game clock
                        db $FC

; Horizontal guardians

                        db $43
                        dw $5C27
                        db $60,$00,$27,$3D

                        db $C4
                        dw $5C90
                        db $60,$00,$87,$9D

                        db $46
                        dw $5CF4
                        db $60,$07,$EA,$FA

                        db $C2
                        dw $5D52
                        db $68,$00,$47,$5D

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $47
                        dw $0800
                        db $05,$02,$08,$64

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ------####------
                        dg ----##----##----
                        dg ---#--------#---
                        dg --#----------#--
                        dg -#------------#-
                        dg #--------------#
                        dg -#------------#-
                        dg --#----------#--
                        dg ##-#--------#-##
                        dg --#-##----##-#--
                        dg -#--#-####-#--#-
                        dg ---#--#--#--#---
                        dg ------#--#------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ------####------
                        dg ----##----##----
                        dg ---#--------#---
                        dg --#----------#--
                        dg -#------------#-
                        dg #####------#####
                        dg -#-#-######-#-#-
                        dg --#-#-####-#-#--
                        dg ---#--#--#--#---
                        dg ----##----##----
                        dg ------####------
                        dg ----------------
                        dg ----------------

                        dg -----#----#-----
                        dg -----#----#-----
                        dg ---#--#--#--#---
                        dg -#--#-####-#--#-
                        dg --#-##----##-#--
                        dg #--#--####--#--#
                        dg #-#--######--#-#
                        dg -#---##--##---#-
                        dg #----##--##----#
                        dg -#---######---#-
                        dg --#---####---#--
                        dg ---#--------#---
                        dg ----##----##----
                        dg ------####------
                        dg ----------------
                        dg ----------------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ------####------
                        dg ----##----##----
                        dg ---#--#--#--#---
                        dg --#-#-#--#-#-#--
                        dg -#-##########-#-
                        dg ####-##--#######
                        dg -#---######---#-
                        dg --#---####---#--
                        dg ---#--------#---
                        dg ----##----##----
                        dg ------####------
                        dg ----------------
                        dg ----------------

                        dg -##----##-------
                        dg #-##--#--#------
                        dg #-##--####------
                        dg -##----##-------
                        dg ----##----------
                        dg ##########------
                        dg -#-#--#-#-------
                        dg ---#--#---------
                        dg ---#--#---------
                        dg ---####---------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ---####---------
                        dg --######--------

                        dg ---##----##-----
                        dg --#--#--##-#----
                        dg --####--##-#----
                        dg ---##----##-----
                        dg ------##--------
                        dg --##########----
                        dg ---#-#--#-#-----
                        dg -----#--#-------
                        dg -----#--#-------
                        dg -----####-------
                        dg ------##--------
                        dg ------##--------
                        dg -----####-------
                        dg ----######------
                        dg ----------------
                        dg ----------------

                        dg -----##----##---
                        dg ----##-#--####--
                        dg ----##-#--#--#--
                        dg -----##----##---
                        dg --------##------
                        dg ----##########--
                        dg -----#-#--#-#---
                        dg -------#--#-----
                        dg -------#--#-----
                        dg -------####-----
                        dg -------####-----
                        dg ------######----
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------

                        dg -------##----##-
                        dg ------####--#-##
                        dg ------#--#--#-##
                        dg -------##----##-
                        dg ----------##----
                        dg ------##########
                        dg -------#-#--#-#-
                        dg ---------#--#---
                        dg ---------#--#---
                        dg ---------####---
                        dg ----------##----
                        dg ----------##----
                        dg ---------####---
                        dg --------######--
                        dg ----------------
                        dg ----------------

; ---------------------------------------------------------------;
;                                                                ;
; Skylab Landing Bay (teleport: 1346)                            ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

; Cavern attributes

                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "6808080808080808080808080808084C0C080808080808080808080808080868"
                                  DH "6808084C0C0808080808084C0C0808080808084C0C0808080808084C0C080868"
                                  DH "680808080808084C0C08080808080808080808080808084C0C08080808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "68080808084C0C0808080808084C0C0808080808084C0C0808080808084C0C68"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "684C0C0808080808084C0C080808084B4B4B4B4B4B080808084C0C0808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "680808080808084C0C0808080808080808080808080808080808080808080868"
                                  DH "6808080808080808080808080808080808080808080808080808080808080868"
                                  DH "6868686868686868686868686868686868686868686868686868686868686868"

; Cavern name

                        db "       Skylab Landing Bay       "

; Background
                        db $08
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $4C
                        dg ########
                        dg ########
                        dg -##---#-
                        dg -##--#--
                        dg -####---
                        dg -###----
                        dg -##-----
                        dg -##-----

; Crumbling floor
                        db $02
                        dg ######--
                        dg ########
                        dg ########
                        dg #----###
                        dg ########
                        dg ----#---
                        dg ----#---
                        dg --------

; Wall
                        db $68
                        dg -------#
                        dg #-----#-
                        dg ##---#--
                        dg ###-#---
                        dg ###-----
                        dg ##-##---
                        dg #-####--
                        dg -######-

; Conveyor
                        db $4B
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $00
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $00
                        dg -#--#---
                        dg #-##--#-
                        dg -#-###-#
                        dg ---#--#-
                        dg -###----
                        dg #-#-###-
                        dg #-#-#--#
                        dg -#---###

; Extra
                        db $0C
                        dg ########
                        dg ########
                        dg -#---##-
                        dg --#--##-
                        dg ---####-
                        dg ----###-
                        dg -----##-
                        dg -----##-

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DBD

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $786F

; Length.
                        db $06

; Border colour
                        db $06

; Unused?
                        db $00

; Item data

                        db $0B
                        dw $5C57
                        db $60,$FF

                        db $0C
                        dw $5D03
                        db $68,$FF

                        db $0D
                        dw $5CFB
                        db $60,$FF

                        db $0E
                        dw $5CF0
                        db $60,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF
; Terminator
                        db $FF


; Portal

                        db $1E
                        dg ################
                        dg ################
                        dg ######----######
                        dg #####------#####
                        dg ####--------####
                        dg ###----------###
                        dg ##-----##-----##
                        dg ##----#--#----##
                        dg ##----#--#----##
                        dg ##-----##-----##
                        dg ###----------###
                        dg ####--------####
                        dg #####------#####
                        dg ######----######
                        dg ################
                        dg ################

; Location
                        dw $5C0F,$600F

; Item graphic

                        dg #-#-#-#-
                        dg #-#-#-#-
                        dg #######-
                        dg #######-
                        dg #######-
                        dg #######-
                        dg #-#-#-#-
                        dg #-#-#-#-

; Air supply
                        db $3F

; Game clock
                        db $F8

; Horizontal guardians

                        db $FF
                        dw $5CE9
                        db $60,$00,$E9,$EE

                        db $C2
                        dw $5D4C
                        db $68,$00,$48,$4E

                        db $43
                        dw $5DA8
                        db $68,$00,$A4,$BA

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $0F
                        dw $0000
                        db $01,$04,$00,$48

                        db $0D
                        dw $0000
                        db $0B,$01,$00,$20

                        db $0E
                        dw $0200
                        db $15,$03,$02,$38

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ------####------
                        dg ################
                        dg #-#-#-####-#-#-#
                        dg ################
                        dg ---#--####--#---
                        dg --#-#--##--#-#--
                        dg ---#-#-##-#-#---
                        dg ----#-####-#----
                        dg -----#-##-#-----
                        dg ------####------
                        dg ------####------
                        dg -----#-##-#-----
                        dg ----#-#--#-#----
                        dg ---#-#----#-#---
                        dg --#-#------#-#--
                        dg ---#--------#---

                        dg ----------------
                        dg ----------------
                        dg ------####------
                        dg ################
                        dg #-#-#-####-#-#-#
                        dg ################
                        dg ---#--####--#---
                        dg --#-#--##--#-#--
                        dg ---#-#-##-#-#---
                        dg ----#-####-#----
                        dg -----#-##-#-----
                        dg ------####------
                        dg ------####------
                        dg --#--#-##-#-----
                        dg -#--#-#--#-#-#--
                        dg ---#-#----#-#-#-

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg -------------###
                        dg ------########-#
                        dg ##########-#-###
                        dg #-#-#-#######---
                        dg ##########------
                        dg ------####------
                        dg -------##-------
                        dg ---#-#-##-#--#--
                        dg -#--#-####-#--#-
                        dg -----#-##-#--#--
                        dg --#---####----#-
                        dg ----#-####-#----
                        dg --#--#-##-#-#---

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------#-----
                        dg ------#-------#-
                        dg -----------#-#-#
                        dg ------####--###-
                        dg ----######-#-#--
                        dg ##--#-####--#---
                        dg #-##-#####----#-
                        dg ###---####--#---
                        dg --##---##------#
                        dg -----######--#--
                        dg ##----####--#---
                        dg ---#-#####----#-
                        dg --#---########--

                        dg ----------------
                        dg -------#--------
                        dg ----------------
                        dg ----#-----#-----
                        dg ----------------
                        dg ----------------
                        dg --#----#------#-
                        dg -----------#---#
                        dg ------###---#-#-
                        dg ----###-#--#----
                        dg -#--#-####------
                        dg --##-###------#-
                        dg -##---#-##------
                        dg --##---#-------#
                        dg -----#-####---#-
                        dg ##----##-#---#--

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ------#---------
                        dg ----------------
                        dg ----------#-----
                        dg ---#--------#---
                        dg ----#-#-#----#--
                        dg ----------#-----
                        dg -##--#-#--------
                        dg --#---#--##-#---
                        dg ----#---#-#-----
                        dg ------####-#----
                        dg ---#-######-----

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ------#---------
                        dg ----------#-----
                        dg ---#------------
                        dg ----------------
                        dg -----#-#---#----
                        dg ---------##-#---
                        dg --#---#-#-#-----
                        dg ----##-###-#----

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg --------#-------
                        dg ----------#-----
                        dg ----#-----------
                        dg ------#-##------
                        dg -----###-##-----

; ---------------------------------------------------------------;
;                                                                ;
; The Bank (teleport: 2346)                                      ;
;                                                                ;
; ---------------------------------------------------------------;
; Cavern attributes

                        dh "0E00000000000E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E0E"
                        dh "0E0000000000000000000000000000000000000000000000000000000006060E"
                        dh "0E0000000000000000000000000000000000000000000000000000000006060E"
                        dh "0E0000000000000045454545454545454545454545454545414141414106060E"
                        dh "0E0000000000000042000000000000000000000000000000000000004206060E"
                        dh "0E4141414141000046000000000000000000000000000000000000004206060E"
                        dh "0E0000000000000000000000000000000000000000000000414100004206060E"
                        dh "0E0000000000000100000000414100000000000000000000000000004206060E"
                        dh "0E0000414100000000000000000000000000414100000000000000004206060E"
                        dh "0E0000000000000000000000000000000000000000000000004141004206060E"
                        dh "0E4141000000000000000000414100000000000000000000000000004606060E"
                        dh "0E0000000000000000000000000000000000414100000000000000000006060E"
                        dh "0E0000000041414100000000000000000000000000000041410000000006060E"
                        dh "0E0000000000000000000000414100000000000000000000000000000006060E"
                        dh "0E0000000000000000000000000000000000000000000000000000000006060E"
                        dh "0E4141414141414141414141414141414141414141414141414141414141410E"

; Cavern name

                        db "            The Bank            "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $41
                        dg ########
                        dg ########
                        dg ##-###-#
                        dg -###-###
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg --#---#-
                        dg --------

; Crumbling floor
                        db $01
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $0E
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#

; Conveyor
                        db $45
                        dg #######-
                        dg -##--##-
                        dg #######-
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $46
                        dg ---#----
                        dg ---#----
                        dg ##-#-##-
                        dg --###---
                        dg ##-#-##-
                        dg --###---
                        dg -#-#-#--
                        dg #--#--#-

; Nasty 2
                        db $42
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----
                        dg ---#----

; Extra
                        db $06
                        dg ########
                        dg ########
                        dg ---##---
                        dg ---##---
                        dg ---##---
                        dg ---##---
                        dg ---##---
                        dg ---##---

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DA2

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $7068

; Length.
                        db $10

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C59
                        db $60,$FF

                        db $04
                        dw $5CCC
                        db $60,$FF

                        db $05
                        dw $5DDA
                        db $68,$FF

                        db $FF
                        dw $5CD3
                        db $60,$FF

                        db $03
                        dw $5DBE
                        db $68,$FF
; Terminator
                        db $FF


; Portal

                        db $56
                        dg ################
                        dg #--------------#
                        dg #--------------#
                        dg #--------------#
                        dg #--------------#
                        dg #---#----------#
                        dg #-#-#-#--------#
                        dg #--###----####-#
                        dg ########-#---###
                        dg #--###---------#
                        dg #-#-#-#--------#
                        dg #---#----------#
                        dg #--------------#
                        dg #--------------#
                        dg #--------------#
                        dg ################

; Location
                        dw $5C61,$6061

; Item graphic

                        dg -#####--
                        dg --###---
                        dg -##--#--
                        dg ##-####-
                        dg #---###-
                        dg ##-####-
                        dg #-----#-
                        dg -#####--

; Air supply
                        db $3F

; Game clock
                        db $FC

; Horizontal guardians

                        db $45
                        dw $5DB1
                        db $68,$00,$B1,$B3

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $06
                        dw $2800
                        db $09,$02,$24,$66

                        db $07
                        dw $4001
                        db $0F,$01,$24,$66

                        db $44
                        dw $5003
                        db $15,$FD,$20,$68

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg -##----##----##-
                        dg #--##########--#
                        dg #--##########--#
                        dg -##----##----##-
                        dg ------####------
                        dg ################
                        dg #--------------#
                        dg #-#-#-#-#-#-#--#
                        dg #--###########-#
                        dg #-##-#-#-#-##--#
                        dg #--#--------##-#
                        dg #-##-#-#-#-##--#
                        dg #--###########-#
                        dg #-#-#-#-#-#-#--#
                        dg #--------------#
                        dg ################

                        dg ---###-##-###---
                        dg --#---#-####-#--
                        dg --#---#-####-#--
                        dg ---###-##-###---
                        dg ------####------
                        dg ################
                        dg ##-#-#-#-#-#-#-#
                        dg #-##############
                        dg ###-#-#-#-#-##-#
                        dg #-##---------###
                        dg ###--#-#-#--##-#
                        dg #-##---------###
                        dg ###-#-#-#-#-##-#
                        dg #-##############
                        dg ##-#-#-#-#-#-#-#
                        dg ################

                        dg -----######-----
                        dg ----#------#----
                        dg ----#------#----
                        dg -----######-----
                        dg ------####------
                        dg ################
                        dg ################
                        dg ##-#-#-#-#-#-###
                        dg ###-----------##
                        dg ##--#-#-#-#--###
                        dg ###--#######--##
                        dg ##--#-#-#-#--###
                        dg ###-----------##
                        dg ##-#-#-#-#-#-###
                        dg ################
                        dg ################

                        dg ---###-##-###---
                        dg --#-####-#---#--
                        dg --#-####-#---#--
                        dg ---###-##-###---
                        dg ------####------
                        dg ################
                        dg #-#-#-#-#-#-#-##
                        dg ##-------------#
                        dg #--#-#-#-#-#--##
                        dg ##--#########--#
                        dg #--##-#-#-##--##
                        dg ##--#########--#
                        dg #--#-#-#-#-#--##
                        dg ##-------------#
                        dg #-#-#-#-#-#-#-##
                        dg ################

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ##########------
                        dg #------###------
                        dg ##########------
                        dg #-----#--#------
                        dg #######--#------
                        dg ##########------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg --##########----
                        dg --#------###----
                        dg --##########----
                        dg --#-----#--#----
                        dg --#######--#----
                        dg --##########----
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----##########--
                        dg ----#------###--
                        dg ----##########--
                        dg ----#-----#--#--
                        dg ----#######--#--
                        dg ----##########--
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ------##########
                        dg ------#------###
                        dg ------##########
                        dg ------#-----#--#
                        dg ------#######--#
                        dg ------##########
                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg ----------------

; ---------------------------------------------------------------;
;                                                                ;
; The Sixteenth Cavern (teleport: 12346)                         ;
;                                                                ;
; ---------------------------------------------------------------;
; Cavern attributes

                        dh "6500000000000000000000000000000000000000000000000000000000000065"
                        dh "6500000000000000000000000000000000000000000000000000000000000065"
                        dh "6500000000000000000000000000000000000000000000000000000000000065"
                        dh "6500000000000000000000000000000000000000000000000000000000000065"
                        dh "6500000000000000000000000000000000000000000000000000000000000065"
                        dh "6542000000004200000000650000650000000000000042424200000000000065"
                        dh "6500000000000000000000650000656500000000000000000000000000000065"
                        dh "6500000042000000000000650000656565000000000000000042424242424265"
                        dh "6500000000000000000000650000656565650000000000000000000000000065"
                        dh "6502024646464646464646464646464646464646464646464646460000000065"
                        dh "6500000000000000000000000000000000000000000000000000000000000065"
                        dh "6500000000000000000065654242000000000000000000000000420000000065"
                        dh "6542424242424242424200000000000000000000000000000000000000000065"
                        dh "6500000000000000000000000000000000000000420000000000420000000065"
                        dh "6500000000000000000000000000000000000000000000040404000000000065"
                        dh "6542424242424242424242424242424242424242424242424242424242424265"

; Cavern name

                        db "      The Sixteenth Cavern      "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $42
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $02
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $65
                        dg -#--#--#
                        dg #####--#
                        dg -#--####
                        dg -#--#--#
                        dg ########
                        dg -#--#---
                        dg -####---
                        dg ##--####

; Conveyor
                        db $46
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg #-#-#-#-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $04
                        dg -#---#--
                        dg -#---#--
                        dg -#---#--
                        dg -#---#--
                        dg -##--##-
                        dg ###-###-
                        dg ###-###-
                        dg ########

; Nasty 2
                        db $05
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $06
                        dg ########
                        dg #------#
                        dg #------#
                        dg -#----#-
                        dg --####--
                        dg ---#----
                        dg -##-----
                        dg -##-----

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DA2

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $7823

; Length.
                        db $18

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C5E
                        db $60,$FF

                        db $04
                        dw $5CED
                        db $60,$FF

                        db $05
                        dw $5C01
                        db $60,$FF

                        db $06
                        dw $5D51
                        db $68,$FF

                        db $FF
                        dw $5CBA
                        db $60,$FF
; Terminator
                        db $FF


; Portal

                        db $5E
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg ################
                        dg #------##------#
                        dg #------##------#
                        dg ################

; Location
                        dw $5CAC,$60AC

; Item graphic

                        dg ----####
                        dg ----#--#
                        dg --####-#
                        dg --#--###
                        dg ####-#--
                        dg #--###--
                        dg #--#----
                        dg ####----

; Air supply
                        db $3F

; Game clock
                        db $F8

; Horizontal guardians

                        db $44
                        dw $5DA9
                        db $68,$00,$A1,$B2

                        db $06
                        dw $5D41
                        db $68,$00,$41,$47

                        db $43
                        dw $5CF2
                        db $60,$00,$F2,$F7

                        db $85
                        dw $5CBA
                        db $60,$00,$B9,$BD

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ----------------
                        dg ----#-----------
                        dg ---#-#----------
                        dg --#-#-#---------
                        dg -#-#-#-#--------
                        dg -#--#-#---------
                        dg #----#----------
                        dg #-------##------
                        dg #-------##------
                        dg -#-----#--------
                        dg -########-------
                        dg --########------
                        dg ---######-------
                        dg ----####--------
                        dg ----#-#-#-------
                        dg ---#--#--#------

                        dg --#-#-#---------
                        dg ---#-#-#--------
                        dg --#-#-#---------
                        dg ---#-#-#--------
                        dg --#-------------
                        dg --#-------------
                        dg --#-------------
                        dg --#-------##----
                        dg --#-------##----
                        dg ---#-----#------
                        dg ---########-----
                        dg ----########----
                        dg -----######-----
                        dg ------####------
                        dg ------#-#-#-----
                        dg -----#--#--#----

                        dg ----------------
                        dg ---#------------
                        dg --#-#-----------
                        dg -#-#-#----------
                        dg #-#-#-#---------
                        dg -#-#---#--------
                        dg --#----#--------
                        dg -------#----##--
                        dg ------#-----##--
                        dg ------#----#----
                        dg ------#######---
                        dg ------########--
                        dg -------######---
                        dg --------####----
                        dg --------#-#-#---
                        dg -------#--#--#--

                        dg -----#-#-#------
                        dg ----#-#-#-------
                        dg -----#-#-#------
                        dg ----#-#-#-------
                        dg ---------#------
                        dg ---------#------
                        dg ---------#------
                        dg ---------#----##
                        dg --------#-----##
                        dg --------#----#--
                        dg --------#######-
                        dg --------########
                        dg ---------######-
                        dg ----------####--
                        dg ----------#-#-#-
                        dg ---------#--#--#

                        dg ------#-#-#-----
                        dg -------#-#-#----
                        dg ------#-#-#-----
                        dg -------#-#-#----
                        dg ------#---------
                        dg ------#---------
                        dg ------#---------
                        dg ##----#---------
                        dg ##-----#--------
                        dg --#----#--------
                        dg -#######--------
                        dg ########--------
                        dg -######---------
                        dg --####----------
                        dg -#-#-#----------
                        dg #--#--#---------

                        dg ----------------
                        dg ------------#---
                        dg -----------#-#--
                        dg ----------#-#-#-
                        dg ---------#-#-#-#
                        dg --------#---#-#-
                        dg --------#----#--
                        dg --##----#-------
                        dg --##-----#------
                        dg ----#----#------
                        dg ---#######------
                        dg --########------
                        dg ---######-------
                        dg ----####--------
                        dg ---#-#-#--------
                        dg --#--#--#-------

                        dg ---------#-#-#--
                        dg --------#-#-#---
                        dg ---------#-#-#--
                        dg --------#-#-#---
                        dg -------------#--
                        dg -------------#--
                        dg -------------#--
                        dg ----##-------#--
                        dg ----##-------#--
                        dg ------#-----#---
                        dg -----########---
                        dg ----########----
                        dg -----######-----
                        dg ------####------
                        dg -----#-#-#------
                        dg ----#--#--#-----

                        dg ----------------
                        dg -----------#----
                        dg ----------#-#---
                        dg ---------#-#-#--
                        dg --------#-#-#-#-
                        dg ---------#-#--#-
                        dg ----------#----#
                        dg ------##-------#
                        dg ------##-------#
                        dg --------#-----#-
                        dg -------########-
                        dg ------########--
                        dg -------######---
                        dg --------####----
                        dg -------#-#-#----
                        dg ------#--#--#---

; ---------------------------------------------------------------;
;                                                                ;
; The Warehouse (teleport: 56)                                   ;
;                                                                ;
; ---------------------------------------------------------------;
; Cavern attributes

                        dh "1600000000000000000000000000000000000000000000000000000000161616"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000600000600000006000006000000000006000600000000000016"
                        dh "1604044444444444444400004444444444444400004444440044440000040416"
                        dh "1644442144444444444400004444444444444400004444444444440000444416"
                        dh "1644444444444444444400004444440044444400004444444444210000444416"
                        dh "1644440000444444444400004444202020202000004444444444440000444416"
                        dh "1600440000444444444400004444444444444400004444444444440000444416"
                        dh "1644440000444444444400004444444444444400444421444444440000444416"
                        dh "1644440000444444442100004444444444444444444444444444000000444416"
                        dh "1644440000444444444400004444444444444444444444444444440000444416"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000404040416"
                        dh "1604040404040404040404040404040404040404040404040404040404040416"

; Cavern name

                        db "         The Warehouse          "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $04
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $44
                        dg ########
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-
                        dg -#-#-#-#
                        dg #-#-#-#-

; Wall
                        db $16
                        dg ########
                        dg #--##--#
                        dg #-###-##
                        dg ########
                        dg ########
                        dg #--##--#
                        dg #-###-##
                        dg ########

; Conveyor
                        db $20
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Nasty 1
                        db $06
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $21
                        dg -#----#-
                        dg ##-#-###
                        dg #######-
                        dg -##--#-#
                        dg #-#--##-
                        dg -#####-#
                        dg ###-###-
                        dg ##-#-###

; Extra
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Pixel y-coordinate * 2.
                        db $30

; Animation frame.
                        db $03

; Direction and movement flags
                        db $01

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5C61

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                        dw $780E

; Length.
                        db $05

; Border colour
                        db $02

; Unused?
                        db $00

; Item data

                        db $23
                        dw $5CB8
                        db $60,$FF

                        db $24
                        dw $5CEF
                        db $60,$FF

                        db $25
                        dw $5D21
                        db $68,$FF

                        db $26
                        dw $5D53
                        db $68,$FF

                        db $23
                        dw $5D7A
                        db $68,$FF
; Terminator
                        db $FF


; Portal

                        db $4C
                        dg ################
                        dg #--------------#
                        dg #-############-#
                        dg #-#----------#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#-########-#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg #-#--#-##-#--#-#
                        dg ################

; Location
                        dw $5C3D,$603D

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $C2
                        dw $5DA5
                        db $68,$00,$A5,$A8

                        db $05
                        dw $5DAC
                        db $68,$00,$AC,$B9

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

                        db $00
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $41
                        dw $4000
                        db $03,$02,$40,$66

                        db $06
                        dw $4001
                        db $0A,$FD,$03,$60

                        db $47
                        dw $3002
                        db $13,$01,$00,$40

                        db $43
                        dw $0003
                        db $1B,$04,$04,$60

; Terminator
                        db $FF

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg ################
                        dg ----#------#----
                        dg ----#------#----
                        dg ----#------#----
                        dg #####------#####
                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg ################
                        dg ----#------#----
                        dg ----#------#----
                        dg ----#------#----
                        dg -#-##------#-#-#
                        dg ################
                        dg ################

                        dg ----------------
                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg ################
                        dg ----#------#----
                        dg #####------#####
                        dg ----#------#----
                        dg --#############-
                        dg --###------####-
                        dg ----#------#----
                        dg -#-#########-#-#
                        dg ################
                        dg ################
                        dg ----------------
                        dg ################
                        dg ----------------

                        dg ----------------
                        dg ----------------
                        dg ################
                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg ################
                        dg ----#------#----
                        dg --###------####-
                        dg --#############-
                        dg ----#------#----
                        dg #####------#####
                        dg -#-#########-#-#
                        dg ################
                        dg ################
                        dg ----------------
                        dg ----------------

                        dg ----------------
                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg #####------#####
                        dg ----#------#----
                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg ################
                        dg -####------###-#
                        dg #####------#####
                        dg #####------#####
                        dg ----#------#----
                        dg -#-#-#-#-#-#-#-#
                        dg ################
                        dg ################
                        dg ----------------

                        dg -######---------
                        dg #--##--#--------
                        dg ########--------
                        dg ##-##-##--------
                        dg ###--###--------
                        dg -######---------
                        dg --#--#----------
                        dg --#--#----------
                        dg --#--#----------
                        dg -#----#---------
                        dg -#----#---------
                        dg -#----#---------
                        dg #------#--------
                        dg #------#--------
                        dg ##----##--------
                        dg ##----##--------

                        dg ----------------
                        dg ---######-------
                        dg --#--##--#------
                        dg --########------
                        dg --##-##-##------
                        dg --###--###------
                        dg ---######-------
                        dg ---#----#-------
                        dg --#------#------
                        dg --#------#------
                        dg -#--------#-----
                        dg -#--------#-----
                        dg #----------#----
                        dg #---------##----
                        dg ##--------##----
                        dg ##--------------

                        dg ----------------
                        dg ----------------
                        dg ----------------
                        dg -----######-----
                        dg ----#--##--#----
                        dg ----########----
                        dg ----##-##-##----
                        dg ----###--###----
                        dg -----######-----
                        dg ----#------#----
                        dg ---#--------#---
                        dg --#----------#--
                        dg -#------------#-
                        dg #--------------#
                        dg ##------------##
                        dg ##------------##

                        dg ----------------
                        dg -------######---
                        dg ------#--##--#--
                        dg ------########--
                        dg ------##-##-##--
                        dg ------###--###--
                        dg -------######---
                        dg -------#----#---
                        dg ------#------#--
                        dg ------#------#--
                        dg -----#--------#-
                        dg -----#--------#-
                        dg ----#----------#
                        dg ----##---------#
                        dg ----##--------##
                        dg --------------##

; ---------------------------------------------------------------;
;                                                                ;
; Amoebatrons' Revenge (teleport: 156)                           ;
;                                                                ;
; ---------------------------------------------------------------;
; Cavern attributes

                        dh "1600000000000000000000000000000000000000000000000000000016000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600004242000042424200004242424242424242000042424200004242424216"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1642420000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000004242424242424242000042424200004242000016"
                        dh "1600004242000042424200000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000424216"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600004242000042424200004242424242424242000042424200004242000016"
                        dh "1642420000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "4242424242424242424242424242424242424242424242424242424242424242"

; Cavern name

                        db "      Amoebatrons' Revenge      "

; Background
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $42
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $02
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $16
                        dg ########
                        dg #------#
                        dg #------#
                        dg ########
                        dg ########
                        dg #------#
                        dg #------#
                        dg ########

; Conveyor
                        db $04
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg #--##--#
                        dg ########
                        dg --------

; Nasty 1
                        db $44
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $05
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $03

; Direction and movement flags
                        db $01

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DBD

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                        dw $7827

; Length.
                        db $03

; Border colour
                        db $01

; Unused?
                        db $00

; Item data

                        db $03
                        dw $5C30
                        db $60,$FF

                        db $FF
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF
; Terminator
                        db $FF


; Portal

                        db $0E
                        dg ################
                        dg #--------------#
                        dg #-##--------##-#
                        dg #-#----------#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#----------#-#
                        dg #-##--------##-#
                        dg #--------------#
                        dg ################

; Location
                        dw $5C1D,$601D

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; Air supply
                        db $3F

; Game clock
                        db $80

; Horizontal guardians

                        db $C4
                        dw $5C6C
                        db $60,$00,$6C,$72

                        db $85
                        dw $5D50
                        db $68,$00,$4C,$51

                        db $43
                        dw $5CD0
                        db $60,$00,$CC,$D1

                        db $06
                        dw $5DB0
                        db $68,$07,$AC,$B2

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $43
                        dw $0800
                        db $05,$03,$05,$68

                        db $04
                        dw $0801
                        db $0A,$02,$05,$68

                        db $05
                        dw $0802
                        db $14,$04,$05,$68

                        db $06
                        dw $0803
                        db $19,$01,$05,$68

; Terminator
                        db $FF

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ------####------
                        dg ----###--###----
                        dg ---#--####--#---
                        dg --##---##---##--
                        dg --###--##--###--
                        dg -#-##########-#-
                        dg #---##-##-##--#-
                        dg #----#--#-#--#--
                        dg -#--#--#--#--#--
                        dg --#-#--#---#--#-
                        dg --#--#--#---#--#
                        dg -#----#--#--#--#
                        dg #-----#--#-#--#-
                        dg -----#--#--#----
                        dg ----#---#---#---
                        dg ---------#------

                        dg ------####------
                        dg ----###--###----
                        dg ---#--####--#---
                        dg --##---##---##--
                        dg --###--##--###--
                        dg -#-##########-#-
                        dg -#--##-##-##---#
                        dg #----#-#---#---#
                        dg #----#--#--#--#-
                        dg -#--#---#-#--#--
                        dg --#-#--#--#--#--
                        dg --#-#--#---#--#-
                        dg -#---#--#---#--#
                        dg ------#--#--#---
                        dg ------#--#-#----
                        dg -----#----------

                        dg ------####------
                        dg ----###--###----
                        dg ---#--####--#---
                        dg --##---##---##--
                        dg --###--##--###--
                        dg -#-##########-#-
                        dg -#--##-##-##---#
                        dg -#---#--#--#---#
                        dg #-----#--#--#--#
                        dg #-----#--#--#-#-
                        dg -#---#--#--#-#--
                        dg --#--#-#--#--#--
                        dg --#-#--#--#---#-
                        dg ----#---#--#----
                        dg -----#---#--#---
                        dg ---------#------

                        dg ------####------
                        dg ----###--###----
                        dg ---#--####--#---
                        dg --##---##---##--
                        dg --###--##--###--
                        dg -#-##########-#-
                        dg -#--##-##-##--#-
                        dg --#-#--#---#--#-
                        dg --#--#--#--#---#
                        dg -#----#--#--#--#
                        dg #-----#--#--#-#-
                        dg #----#---#--#-#-
                        dg -#--#---#--#---#
                        dg ----#--#--#-----
                        dg ----#--#--------
                        dg --------#-------

                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ----##----------
                        dg ##########------
                        dg ----##----------
                        dg -##----##-------
                        dg ##-#--#-##------
                        dg #-##--##-#------
                        dg -##----##-------

                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg ------##--------
                        dg --##########----
                        dg ------##--------
                        dg ---##----##-----
                        dg --#--#--##-#----
                        dg --####--##-#----
                        dg ---##----##-----

                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg --------##------
                        dg ----##########--
                        dg --------##------
                        dg -----##----##---
                        dg ----#-##--##-#--
                        dg ----##-#--#-##--
                        dg -----##----##---

                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ----------##----
                        dg ------##########
                        dg ----------##----
                        dg -------##----##-
                        dg ------#--#--##-#
                        dg ------####--##-#
                        dg -------##----##-

; ---------------------------------------------------------------;
;                                                                ;
; Solar Power Generator (teleport: 256)                          ;
;                                                                ;
; ---------------------------------------------------------------;

SolarPowerGeneratorData           DH "1616162424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242020242424242020202020202424242424242424242020202020202016"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242424242424242424242424242424242420202024242424242424242416"
                                  DH "1620202424242424242424242420202024242424242424242020202020202016"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1624242424242424242424242424242424242420202424242424242424242416"
                                  DH "1620202020242424242424242424242424242424242424242020202020202016"
                                  DH "1624242424242426262626242424202020202024242424242424242424242416"
                                  DH "1624242424242424242424242424242424242424242424242424242424242416"
                                  DH "1616162424242424242424242424242424242424242424242424242424242416"
                                  DH "1616162020202020202020202020202020202020202020162020202020202016"

; Cavern name

                        db "     Solar Power Generator      "

; Background
                        db $24
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Floor
                        db $20
                        dg ########
                        dg ########
                        dg ##-##-##
                        dg -##-###-
                        dg ##---#-#
                        dg -#------
                        dg --------
                        dg --------

; Crumbling floor
                        db $02
                        dg ########
                        dg ##-##-##
                        dg #-#--#-#
                        dg --#--#--
                        dg -#-#--#-
                        dg --#-----
                        dg ----#---
                        dg --------

; Wall
                        db $16
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########
                        dg --#---#-
                        dg ########
                        dg #---#---
                        dg ########

; Conveyor
                        db $26
                        dg ####----
                        dg -##--##-
                        dg ####----
                        dg -##--##-
                        dg --------
                        dg #--##--#
                        dg ########
                        dg --------

; Nasty 1
                        db $44
                        dg -#---#--
                        dg --#-#---
                        dg #--#-#--
                        dg -#-#---#
                        dg --##-#-#
                        dg ##-#-##-
                        dg -#-##---
                        dg ---#----

; Nasty 2
                        db $05
                        dg -######-
                        dg --####--
                        dg ---###--
                        dg ---##---
                        dg ---##---
                        dg ----#---
                        dg ----#---
                        dg ----#---

; Extra
                        db $00
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------
                        dg --------

; Pixel y-coordinate * 2.
                        db $A0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $00

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5D4E

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $00

; Location in the screen buffer
                        dw $7887

; Length.
                        db $04

; Border colour
                        db $03

; Unused?
                        db $00

; Item data

                        db $23
                        dw $5C3E
                        db $60,$FF

                        db $24
                        dw $5CA1
                        db $60,$FF

                        db $25
                        dw $5D9E
                        db $68,$FF

                        db $FF
                        dw $FFFF
                        db $FF,$FF

                        db $00
                        dw $FFFF
                        db $FF,$FF
; Terminator
                        db $FF


; Portal

                        db $4E
                        dg ################
                        dg #--------------#
                        dg #-############-#
                        dg #-#----------#-#
                        dg #-#-########-#-#
                        dg #-#-#------#-#-#
                        dg #-#-#-####-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-#--#-#-#-#
                        dg #-#-#-####-#-#-#
                        dg #-#-#------#-#-#
                        dg #-#-########-#-#
                        dg #-#----------#-#
                        dg #-############-#
                        dg #--------------#
                        dg ################

; Location
                        dw $5C21,$6021

; Item graphic

                        dg --##----
                        dg -#--#---
                        dg #---#---
                        dg #--#----
                        dg -##-#---
                        dg -----#--
                        dg ----#-#-
                        dg -----#--

; Air supply
                        db $3F

; Game clock
                        db $F0

; Horizontal guardians

                        db $26
                        dw $5C78
                        db $60,$00,$77,$7D

                        db $21
                        dw $5CDC
                        db $60,$00,$D6,$DD

                        db $A2
                        dw $5D3D
                        db $68,$07,$37,$3D

                        db $26
                        dw $5DB0
                        db $68,$00,$AD,$BD

; Terminator
                        db $FF

; Unused?
                        db $00,$00

; Vertical guardians

                        db $26
                        dw $4000
                        db $05,$03,$02,$66

                        db $22
                        dw $3801
                        db $0B,$FE,$30,$66

                        db $21
                        dw $5002
                        db $10,$01,$04,$50

                        db $FF
                        dw $0000
                        db $00,$00,$00,$00

; Terminator
                        db $00

; Unused?
                        db $00,$00,$00,$00,$00,$00


                        dg ------##-#------
                        dg ----####-###----
                        dg --######--####--
                        dg --######-#--##--
                        dg -#-#####-##--##-
                        dg -#-#####-###-##-
                        dg #--#####-#######
                        dg ---------#######
                        dg #---###---------
                        dg #---###-########
                        dg -#---##-#######-
                        dg -#------####--#-
                        dg --#----------#--
                        dg --##--------##--
                        dg ----##----##----
                        dg ------#-##------

                        dg ------####------
                        dg ----########----
                        dg --#######-#-##--
                        dg --########--##--
                        dg -#-#######---##-
                        dg -#---####-##-##-
                        dg #--##--##-######
                        dg #--####--#######
                        dg #---###--#######
                        dg #---##-##--#####
                        dg -#---#-####--##-
                        dg -#-----#####--#-
                        dg --#----------#--
                        dg --##--------##--
                        dg ----##----##----
                        dg ------####------

                        dg ------####------
                        dg ----########----
                        dg --#-#####-####--
                        dg --##-#####--#---
                        dg -#-##-#####--##-
                        dg -#-###-####--##-
                        dg #--####-##-#####
                        dg #--####---######
                        dg #---##---#######
                        dg #---#-##-#######
                        dg -#---####-#####-
                        dg -#-----###----#-
                        dg -------------#--
                        dg --##---------#--
                        dg ----##----##----
                        dg ------####------

                        dg ------####------
                        dg ----#-######----
                        dg --####-##-####--
                        dg --####-###--##--
                        dg -#-###-####--##-
                        dg -#-####-####-#--
                        dg #--####-###---##
                        dg #--####----#####
                        dg #---#----#######
                        dg #----###-#######
                        dg -----###-######-
                        dg -#-----##-##--#-
                        dg --#----------#--
                        dg --##--------##--
                        dg ----##-----#----
                        dg ------####------

                        dg -----##---------
                        dg ----##----------
                        dg ---##-----------
                        dg --###-----------
                        dg -###-#----------
                        dg ##--#-#-#-------
                        dg #----#-###------
                        dg ------####------
                        dg -----##--#------
                        dg ##--###-##------
                        dg ##-##----#------
                        dg ##########------
                        dg ###---#---------
                        dg ##--#---#-------
                        dg ##-#-#-#-#------
                        dg ----#---#-------

                        dg -------##-------
                        dg ------##--------
                        dg -----##---------
                        dg ----###---------
                        dg ---###-#--------
                        dg --##--#-#-#-----
                        dg --#----#-###----
                        dg --------####----
                        dg -------##--#----
                        dg -##---###-##----
                        dg -##--##----#----
                        dg -###########----
                        dg -####---#-------
                        dg -##---#---#-----
                        dg -##--#-#-#-#----
                        dg ------#---#-----

                        dg ---------##-----
                        dg --------##------
                        dg -------##-------
                        dg ------###-------
                        dg -----###-#------
                        dg ----##--#-#-#---
                        dg ----#----#-###--
                        dg ----------####--
                        dg ---------##--#--
                        dg --##----###-##--
                        dg --##---##----#--
                        dg --############--
                        dg --#####---#-----
                        dg --##----#---#---
                        dg --##---#-#-#-#--
                        dg --------#---#---

                        dg -----------##---
                        dg ----------##----
                        dg ---------##-----
                        dg --------###-----
                        dg -------###-#----
                        dg ------##--#-#-#-
                        dg ------#----#-###
                        dg ------------####
                        dg -----------##--#
                        dg -----##---###-##
                        dg -----##--##----#
                        dg -----###########
                        dg -----####---#---
                        dg -----##---#---#-
                        dg -----##--#-#-#-#
                        dg ----------#---#-

; ---------------------------------------------------------------;
;                                                                ;
; The Final Barrier. (teleport: 1256)                            ;
;                                                                ;
; ---------------------------------------------------------------;

; The first 512 bytes are the attributes that define the layout of the cavern.

TheFinalBarrierData               DH "2C22222222222C28282828282F2F2F2F2F28282828282E32322E282828282828"
                                  DH "2C22222222222C28282F28282F2F2F2F2F28282828283A38383A2828282A2A2A"
                                  DH "2C222216222C2E2E2E2E2E2E2F2F2F2F2F2E2B2E2B2E3A38383A2F2F2F2A2A2A"
                                  DH "282C2C162C2E2E2E2E2E2E2E2E2828282C2C2C2C2C2C3A3A3A3A2F2F2F282A28"
                                  DH "282F2816282E2E2E2E2E2E2E2E2C2C2C26262626262626262626262626262626"
                                  DH "282C2C162C2E2E2E2E2E2E2E2E27262626262600002600000000000000000026"
                                  DH "0C262626262121210E0E21212127262626262600002600000000000000000026"
                                  DH "2626262626262626262626262626262626262600002600000000000000000026"
                                  DH "2600000000000000000000000000000000000000000000000000000000424226"
                                  DH "2600000000000000000000000000000000000000000000000000000000000026"
                                  DH "2605050505050505050505050505050505050505050505000000020000000026"
                                  DH "2600000000000000004400004400000000440000004400000000000042000026"
                                  DH "2642420000000000000000000000000000000000000000000000000000000026"
                                  DH "2600000000424200000000000000000000000000000000000000000000000026"
                                  DH "2600000000000000000000000000000000000000000000000000000000000026"
                                  DH "2642424242424242424242424242424242424242424242424242424242424226"

; Cavern name

                                  db "        The Final Barrier       "

; Background
                                  db $00
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------

; Floor
                                  db $42
                                  dg ########
                                  dg ########
                                  dg ##-##-##
                                  dg -##-###-
                                  dg ##---#-#
                                  dg -#------
                                  dg --------
                                  dg --------

; Crumbling floor
                                  db $02
                                  dg ########
                                  dg ##-##-##
                                  dg #-#--#-#
                                  dg --#--#--
                                  dg -#-#--#-
                                  dg --#-----
                                  dg ----#---
                                  dg --------

; Wall
                                  db $26
                                  dg --#---#-
                                  dg ########
                                  dg #---#---
                                  dg ########
                                  dg --#---#-
                                  dg ########
                                  dg #---#---
                                  dg ########

; Conveyor
                                  db $05
                                  dg ####----
                                  dg -##--##-
                                  dg ####----
                                  dg -##--##-
                                  dg --------
                                  dg #--##--#
                                  dg ########
                                  dg --------

; Nasty 1
                                  db $44
                                  dg ---#----
                                  dg ---#----
                                  dg ##-#-##-
                                  dg --###---
                                  dg ##-#-##-
                                  dg --###---
                                  dg -#-#-#--
                                  dg #--#--#-

; Nasty 2
                                  db $0A
                                  dg -######-
                                  dg --####--
                                  dg ---###--
                                  dg ---##---
                                  dg ---##---
                                  dg ----#---
                                  dg ----#---
                                  dg ----#---

; Extra
                                  db $00
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------
                                  dg --------

; Pixel y-coordinate * 2.
                        db $D0

; Animation frame.
                        db $00

; Direction and movement flags
                        db $01

; Airborne status indicator.
                        db $00

; Location in the attribute buffer at 23970
                        dw $5DBB

; Jumping animation counter
                        db $00

; Conveyor

; Direction
                        db $01

; Location in the screen buffer
                                  dw $7841

; Length.
                                  db $16

; Border colour
                                  db $02

; Unused?
                                  db $00

; Item data

                                  db $03
                                  dw $5CB7
                                  db $60,$FF

                                  db $04
                                  dw $5CDE
                                  db $60,$FF

                                  db $05
                                  dw $5D6A
                                  db $68,$FF

                                  db $06
                                  dw $5D6E
                                  db $68,$FF

                                  db $03
                                  dw $5D73
                                  db $68,$FF
; Terminator
                                  db $FF


; Portal

                                  db $1E
                                  dg ----------------
                                  dg -----######-----
                                  dg ---##------##---
                                  dg --#---####---#--
                                  dg -#---#----#---#-
                                  dg -#--#------#--#-
                                  dg -#--#------#--#-
                                  dg -#--#------#--#-
                                  dg -#---#----#---#-
                                  dg --#---#--#---#--
                                  dg ---##-#--#-##---
                                  dg -#--#-#--#-#--#-
                                  dg -####-#--#-####-
                                  dg -#----#--#----#-
                                  dg -######--######-
                                  dg ----------------

; Location
                                  dw $5CB3,$60B3

; Item graphic

                                  dg --##----
                                  dg -#--#---
                                  dg #---#---
                                  dg #--#----
                                  dg -##-#---
                                  dg -----#--
                                  dg ----#-#-
                                  dg -----#--

; Air supply
                                  db $3F

; Game clock
                                  db $FC

; Horizontal guardians

                                  db $46
                                  dw $5DA7
                                  db $68,$00,$A7,$B6

                                  db $FF
                                  dw $0000
                                  db $00,$00,$00,$00

                                  db $00
                                  dw $0000
                                  db $00,$00,$00,$00

                                  db $00
                                  dw $0000
                                  db $00,$00,$00,$00

; Terminator
                                  db $FF

; Unused?
                                  db $00,$00

; Vertical guardians

                                  db $07
                                  dw $3000
                                  db $18,$01,$28,$67

                                  db $FF
                                  dw $0000
                                  db $00,$00,$00,$00

                                  db $00
                                  dw $0000
                                  db $00,$00,$00,$00

                                  db $00
                                  dw $0000
                                  db $00,$00,$00,$00

; Terminator
                                  db $00

; Unused?
                                  db $00,$00,$00,$00,$00,$00


                                  dg ----------------
                                  dg ----------------
                                  dg ----------------
                                  dg ------####------
                                  dg ----##----##----
                                  dg ---#--------#---
                                  dg --#----------#--
                                  dg -#------------#-
                                  dg #--------------#
                                  dg -#------------#-
                                  dg --#----------#--
                                  dg ##-#--------#-##
                                  dg --#-##----##-#--
                                  dg -#--#-####-#--#-
                                  dg ---#--#--#--#---
                                  dg ------#--#------

                                  dg ----------------
                                  dg ----------------
                                  dg ----------------
                                  dg ------####------
                                  dg ----##----##----
                                  dg ---#--------#---
                                  dg --#----------#--
                                  dg -#------------#-
                                  dg #####------#####
                                  dg -#-#-######-#-#-
                                  dg --#-#-####-#-#--
                                  dg ---#--#--#--#---
                                  dg ----##----##----
                                  dg ------####------
                                  dg ----------------
                                  dg ----------------

                                  dg -----#----#-----
                                  dg -----#----#-----
                                  dg ---#--#--#--#---
                                  dg -#--#-####-#--#-
                                  dg --#-##----##-#--
                                  dg #--#--####--#--#
                                  dg #-#--######--#-#
                                  dg -#---##--##---#-
                                  dg #----##--##----#
                                  dg -#---######---#-
                                  dg --#---####---#--
                                  dg ---#--------#---
                                  dg ----##----##----
                                  dg ------####------
                                  dg ----------------
                                  dg ----------------

                                  dg ----------------
                                  dg ----------------
                                  dg ----------------
                                  dg ------####------
                                  dg ----##----##----
                                  dg ---#--#--#--#---
                                  dg --#-#-#--#-#-#--
                                  dg -#-##########-#-
                                  dg ####-##--#######
                                  dg -#---######---#-
                                  dg --#---####---#--
                                  dg ---#--------#---
                                  dg ----##----##----
                                  dg ------####------
                                  dg ----------------
                                  dg ----------------

                                  dg ---#--#---------
                                  dg ----##----------
                                  dg ---####---------
                                  dg #-######-#------
                                  dg -###--###-------
                                  dg -###--###-------
                                  dg #-######-#------
                                  dg -#-####-#-------
                                  dg -#--##--#-------
                                  dg -#-#--#-#-------
                                  dg -########-------
                                  dg ----##----------
                                  dg -##----##-------
                                  dg #--#--#-##------
                                  dg #-##--#--#------
                                  dg -##----##-------

                                  dg ------##--------
                                  dg -----####-------
                                  dg -----####-------
                                  dg ---###--###-----
                                  dg --###-##-###----
                                  dg --###-##-###----
                                  dg ---###--###-----
                                  dg ---#-####-#-----
                                  dg ---#-####-#-----
                                  dg ---#--##--#-----
                                  dg ---########-----
                                  dg ------##--------
                                  dg ---##----##-----
                                  dg --#--#--#--#----
                                  dg --##-#--#-##----
                                  dg ---##----##-----

                                  dg -------####-----
                                  dg -------####-----
                                  dg -------#--#-----
                                  dg ----###-##-###--
                                  dg ----##-####-##--
                                  dg ----##-####-##--
                                  dg ----###-##-###--
                                  dg -----#-#--#-#---
                                  dg -----#-####-#---
                                  dg -----#-####-#---
                                  dg -----########---
                                  dg --------##------
                                  dg -----##----##---
                                  dg ----##-#--#--#--
                                  dg ----#--#--##-#--
                                  dg -----##----##---

                                  dg ---------####---
                                  dg ---------#--#---
                                  dg ----------##----
                                  dg ------##-####-##
                                  dg ------#-######-#
                                  dg ------#-######-#
                                  dg ------##-####-##
                                  dg -------#--##--#-
                                  dg -------#-#--#-#-
                                  dg -------#-####-#-
                                  dg -------########-
                                  dg ----------##----
                                  dg -------##----##-
                                  dg ------#-##--##-#
                                  dg ------#--#--#--#
                                  dg -------##----##-


; Stop planting code after this. (When generating a tape file we save bytes below here).

AppLast                           EQU *-1                                  ; The last used byte's address.

; Setup the emulation registers, so Zeus can emulate this code correctly.

Zeus_PC                           EQU AppEntry                             ; Tell the emulator where to start.
Zeus_SP                           EQU MemTop                               ; Tell the emulator where to put the stack.

; Tape options

                                  IF enabled bGenerateZ80
                                      output_z80 sFileName+".z80"     ;
                                  ENDIF

                                  IF enabled bGenerateSZX
                                      output_szx sFileName+".szx"     ;
                                  ENDIF

; For some reason Spectaculator isn't loading the tzx file correctly first time, only if LOAD "" is typed manually when running. Very curious.

        if enabled bGenerateTAP or enabled bGenerateTZX

        ; This is a loading screen, we want one for the tap and tzx files

                        ORG $4000

                        dh "2200000000000000003000FF00000000FF000000000000000000000000300022"
                        dh "2200000000000000000000000000000030000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000443000004400000022"
                        dh "22FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF22"
                        dh "2200000000000000000000000000000000000000000000000000000000003022"
                        dh "22FFFFFF00000000007D00000000000000000000000000000000000000000022"
                        dh "FF00000000000000004800FE00000000FE0000000000000000000000004800FF"
                        dh "FF000000000000000000000000000000480000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000002848000028000000FF"
                        dh "FFFFFFFFFFFFFFFFFFFFFFFFFFFFDBDBDBDBFFDBDBDBDBFFFFFFFFFFFFFFFFFF"
                        dh "FF000000000000000000000000000000000000000000000000000000000048FF"
                        dh "FFFFFFFF0000000000E7000000000000000000000000000000000000000000FF"
                        dh "88000000000000000088007E000000007E000000000000000000000000880088"
                        dh "8800000000000000000000000000000088000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000948800009400000088"
                        dh "88DBDBDBDBDBDBDBDBDBDBDBDBDBA5A5A5A5DBA5A5A5A5DBDBDBDBDBDBDBDB88"
                        dh "8800000000000000000000000000000000000000000000000000000000008888"
                        dh "88DBDBDB00000000006700000000000000000000000000000000000000000088"
                        dh "FF000000000000000090007C000000007C0000000000000000000000009000FF"
                        dh "FF000000000000000000000000000000900000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000005190000051000000FF"
                        dh "FF6E6E6E6E6E6E6E6E6E6E6E6E6E242424246E242424246E6E6E6E6E6E6E6EFF"
                        dh "FF000000000000000000000000000000000000000000000000000000000090FF"
                        dh "FF6E6E6E00000000003D000000000000000000000000000000000000000000FF"
                        dh "22000000000000000068004C000000004C000000000000000000000000680022"
                        dh "2200000000000000000000000000000068000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000356800003500000022"
                        dh "22C5C5C5C5C5C5C5C5C5C5C5C5C552525252C552525252C5C5C5C5C5C5C5C522"
                        dh "2200000000000000000000000000000000000000000000000000000000006822"
                        dh "22C5C5C500000000007C00000000000000000000000000000000000000000022"
                        dh "FF000000000000000004004C000000004C0000000000000000000000000400FF"
                        dh "FF000000000000000000000000000000040000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF00000000000000000000000000000000000000000000D6040000D6000000FF"
                        dh "FF404040404040404040404040402020202040202020204040404040404040FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000004FF"
                        dh "FF40404000000000007F000000000000000000000000000000000000000000FF"
                        dh "8800000000000000000A000800000000080000000000000000000000000A0088"
                        dh "880000000000000000000000000000000A000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000580A00005800000088"
                        dh "8800000000000000000000000000080808080008080808000000000000000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000A88"
                        dh "880000000000000003FC00000000000000000000000000000000000000000088"
                        dh "FF000000000000000004000800000000080000000000000000000000000400FF"
                        dh "FF000000000000000000000000000000040000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000001004000010000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000004FF"
                        dh "FF000000000000000078000000000000000000000000000000000000000000FF"
                        dh "2200000000000000007C00000000000000222222004400000000000000000022"
                        dh "22FFFFFFFF0000000F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F00000022"
                        dh "2200000000000000000000000000000000000000000000000000000000FFFF22"
                        dh "2200000000000000000000000000000000000000000000000000000000000022"
                        dh "2200000000000000000000004400000000000000222222FFFFFFFFFFFFFFFF22"
                        dh "2200060000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000FFFF22"
                        dh "22007E0000000000000000000000000000000000000000000000000000B6DB22"
                        dh "22FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF22"
                        dh "FF00000000000000007F00000000000000FFFFFF0028000000000000000000FF"
                        dh "FFFFFFFFFF0000006666666666666666666666666666666666666666000000FF"
                        dh "FF00000000000000000000000000000000000000000000000000000000FFFFFF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF00000000000000000000002800000000000000FFFFFFDBDBDBDBDBFFFFFFFF"
                        dh "FF003E0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000009249FF"
                        dh "FF007E0000000000000000000000000000000000000000000000000000FFFFFF"
                        dh "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
                        dh "8800000000000000003800000000000000888888009400000000000000000088"
                        dh "88DBDBDBDB0000000F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F00000088"
                        dh "8800000000000000000000000000000000000000000000000000000000DBDB88"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000009400000000000000888888A5A5A5A5A5DBDBDB88"
                        dh "88007C0000DBDBDBDBDBDBDBDBDBDBDBDBDBDBDB000000000000000000B6DB88"
                        dh "8800F70000000000000000000000000000000000000000000000000000924988"
                        dh "88DBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDB88"
                        dh "FF00000000000000003800000000000000FFFFFF0051000000000000000000FF"
                        dh "FF6E6E6E6E0000006666666666666666666666666666666666666666000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000006E6EFF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF00000000000000000000005100000000000000FFFFFF24242424246E6E6EFF"
                        dh "FF003400006E6E6E6E6E6E6E6E6E6E6E6E6E6E6E000000000000000000FFFFFF"
                        dh "FF00FB0000000000000000000000000000000000000000000000000000B6DBFF"
                        dh "FF6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6EFF"
                        dh "2200000000000000006C00000000000000222222003500000000000000000022"
                        dh "22C5C5C5C5000000000000000000000000000000000000000000000000000022"
                        dh "2200000000000000000000000000000000000000000000000000000000C5C522"
                        dh "2200000000000000000000000000000000000000000000000000000000000022"
                        dh "22000000000000000000000035000000000000002222225252525252C5C5C522"
                        dh "22003E0000C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5000000000000000000924922"
                        dh "22003C0000000000000000000000000000000000000000000000000000FFFF22"
                        dh "22C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C522"
                        dh "FF00000000000000006C00000000000000FFFFFF00D6000000000000000000FF"
                        dh "FF404040400000009999999999999999999999999999999999999999000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000004040FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF0000000000000000000000D600000000000000FFFFFF2020202020404040FF"
                        dh "FF003C0000404040404040404040404040404040000000000000000000B6DBFF"
                        dh "FF007600000000000000000000000000000000000000000000000000009249FF"
                        dh "FF404040404040404040404040404040404040404040404040404040404040FF"
                        dh "880000000000000001C700000000000000888888005800000000000000000088"
                        dh "8800000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "8800000000000000000000005800000000000000888888080808080800000088"
                        dh "8800180000000000000000000000000000000000000000000000000000FFFF88"
                        dh "88006E0000000000000000000000000000000000000000000000000000B6DB88"
                        dh "8800000000000000000000000000000000000000000000000000000000000088"
                        dh "FF00000000000000006C00000000000000FFFFFF0010000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FF00000000000000000000001000000000000000FFFFFF0000000000000000FF"
                        dh "FF003C00000000000000000000000000000000000000000000000000009249FF"
                        dh "FF00770000000000000000000000000000000000000000000000000000FFFFFF"
                        dh "FF000000000000000000000000000000000000000000000000000000000000FF"
                        dh "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "0600060000000000000000000000000000000000000000000000000000000000"
                        dh "7E007E0000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFC3FFFFEFFFFFEFFFC3FFFFFFFFFFFFFFFFFFFFFFFFFFFF"
                        dh "3C3E7C0000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "42100040003C00000000003C3C3C3C3C3C0000003C00000000003C3C3C3C3C3C"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "3E003E0000000000000000000000000000000000000000000000000000000000"
                        dh "7E007E0000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFBDC787C7E3C7EFFFBDC7BBC7E387FFFFFFFFFFFFFFFFFF"
                        dh "42084200FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "42003C4000401C381C3800464646464646000000401C381C3800464646464646"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "7C007C0000000000000000000000000000000000000000000000000000000000"
                        dh "F700F70000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFBFBBBBEFDFFBEFFFBFFBBBBBDFBBFFFFFFFFFFFFFFFFFF"
                        dh "42084200FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "7E304478003C20442044004A4A4A4A4A4A0000003C20442044004A4A4A4A4A4A"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "3400340000000000000000000000000000000000000000000000000000000000"
                        dh "FB00FB0000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFBF87BBEFDFC3EFFFBFC3D787DFBBFFFFFFFFFFFFFFFFFF"
                        dh "7E087C00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "4210444400022044207800525252525252000000022044207800525252525252"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "3E003E0000000000000000000000000000000000000000000000000000000000"
                        dh "3C003C0000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFBDBFBBEFDFBBEFFFBDBBD7BFDFBBFFFFFFFFFFFFFFFFFF"
                        dh "42084400FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "42103C4400422044204000626262626262000000422044204000626262626262"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "3C003C0000000000000000000000000000000000000000000000000000000000"
                        dh "7600760000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFC3C3BBF3DFC3F3FFC3C3EFC3DFBBFFFFFFFFFFFFFFFFFF"
                        dh "423E420000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "42380444003C1C38203C003C3C3C3C3C3C0000003C1C38203C003C3C3C3C3C3C"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "1800180000000000000000000000000000000000000000000000000000000000"
                        dh "6E006E0000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "0000380000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "3C003C0000000000000000000000000000000000000000000000000000000000"
                        dh "7700770000000000000000000000000000000000000000000000000000000000"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"
                        dh "1600000000000000000500050000000005000000000000000000000000060016"
                        dh "1600000000000000000000000000000003000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000000000000000000000000000440400004400000016"
                        dh "1642424242424242424242424242020202024202020202424242424242424216"
                        dh "1600000000000000000000000000000000000000000000000000000000000516"
                        dh "1642424200000000464600000000000000000000000000000000000000000016"
                        dh "1600000000000000464600000000000000161616004400000000000000000016"
                        dh "1642424242000000040404040404040404040404040404040404040400000016"
                        dh "1600000000000000000000000000000000000000000000000000000000424216"
                        dh "1600000000000000000000000000000000000000000000000000000000000016"
                        dh "1600000000000000000000004400000000000000161616020202020242424216"
                        dh "16000707004242424242424242424242424242420000000000000000000E0E16"
                        dh "16000707000000000000000000000000000000000000000000000000000E0E16"
                        dh "1642424242424242424242424242424242424242424242424242424242424216"
                        dh "0606060606060606060606060606060606060606060606060606060606060606"
                        dh "5757575757575757575767676767676767676767676767676767676767676767"
                        dh "4646464646464646464646464646464646464646464646464646464646464646"
                        dh "4646464646464646464646464646464646464646464646464646464646464646"
                        dh "4646464646464646464646464646464646464646464646464646464646464646"
                        dh "4545454545454545454545454545454545454545454545454545454545454545"
                        dh "4545454545454545454545454545454545454545454545454545454545454545"
                        dh "0000000000000000000000000000000000000000000000000000000000000000"

          if enabled bGenerateTAP
            output_tap sFileName+".tzx",sFileName,"",AppFirst,AppLast-AppFirst,3,AppEntry,$04243465 ; A tap file using the loader
          endif

          if enabled bGenerateTZX
            output_tzx sFileName+".tzx",sFileName,"",AppFirst,AppLast-AppFirst,3,AppEntry,$04243465 ; A tzx file using the loader
          endif

        endif

; Import the original binary file for comparison if you want to check the reliability of this source...

        if enabled bPerformComparison
          if zeusgetfilelength(sFileName+".bin") > 0 ; Assuming it exists...
            import_comparison sFileName+".bin",0    ; Import a comparison file
          else
            zeusprint "Sorry, I can't find """+sFileName+".bin"+""" to compare with..."
          endif
        endif


