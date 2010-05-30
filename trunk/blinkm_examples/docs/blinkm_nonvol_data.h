/*
 * BlinkM non-volatile data
 *
 */

// comment out to remove ROM scripts
#define INCLUDE_ROM_SCRIPTS

// define in makefile so each gets their own
#ifndef I2C_ADDR
#define I2C_ADDR 0x09
#endif

// number of of script ticks per 'w'ait command
//  30.52 script ticks == 1 second
//  153   script ticks == 5.013 seconds
//  255   script ticks == 8.35 seconds
//#define SCRIPT_TICKS_PER_WAIT_TICK 153
#define SCRIPT_TICKS_PER_WAIT_TICK 153


// possible values for boot_mode
#define BOOT_NOTHING     0
#define BOOT_PLAY_SCRIPT 1
#define BOOT_MODE_END    2

#define MAX_EE_SCRIPT_LEN 49

typedef struct _script_line {
    uint8_t dur; 
    uint8_t cmd[4];    // cmd,arg1,arg2,arg3
} script_line;

typedef struct _script {
    uint8_t len;  // number of script lines, 0 == blank script, not playing
    uint8_t reps; // number of times to repeat, 0 == infinite playes
    script_line lines[];
} script;

#ifdef INCLUDE_ROM_SCRIPTS
// R,G,B,R,G,B,....
const script fl_script_rgb PROGMEM = {
    3, // number of lines
    0, // number of repeats
    {
        { 50, {'c', 0xff,0x00,0x00}},
        { 50, {'c', 0x00,0xff,0x00}},
        { 50, {'c', 0x00,0x00,0xff}},
    }
};
// white blink on & off
const script fl_script_blink_white PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0xff,0xff,0xff}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// red blink on & off
const script fl_script_blink_red PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0xff,0x00,0x00}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// green blink on & off
const script fl_script_blink_green PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0x00,0xff,0x00}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// blue blink on & off
const script fl_script_blink_blue PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0x00,0x00,0xff}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// cyan blink on & off
const script fl_script_blink_cyan PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0x00,0xff,0xff}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// magenta blink on & off
const script fl_script_blink_magenta PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0xff,0x00,0xff}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// yellow blink on & off
const script fl_script_blink_yellow PROGMEM = {
    2, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0xff,0xff,0x00}},
        { 20, {'c', 0x00,0x00,0x00}},
    }
};
// black (off)
const script fl_script_black PROGMEM = {
    1, // number of lines
    0, // number of repeats
    {
        { 20, {'c', 0x00,0x00,0x00}},
    }
};

// hue cycle
const script fl_script_hue_cycle PROGMEM = {
    7, // number of lines
    0, // number of repeats
    {
        { 30, {'h', 0x00,0xff,0xff}},  // red
        { 30, {'h', 0x2a,0xff,0xff}},  // yellow 
        { 30, {'h', 0x54,0xff,0xff}},  // green
        { 30, {'h', 0x7e,0xff,0xff}},  // cyan
        { 30, {'h', 0xa8,0xff,0xff}},  // blue
        { 30, {'h', 0xd2,0xff,0xff}},  // magenta
        { 30, {'h', 0xff,0xff,0xff}},  // red
    }
};

// Random color mood light
const script fl_script_randmood PROGMEM = {
    1, // number of lines
    0, // number of repeats
    {
        {50, {'H', 0x80,0x00,0x00}}, // random fade to other hues
    }
};

// virtual candle
const script fl_script_candle PROGMEM = {
    16, // number of lines
    0,  // number of repeats
    {
        {  1, {'f',   10,0x00,0x00}}, // set color_step (fade speed) 
        { 50, {'h', 0x10,0xff,0xff}}, // set orange
        {  2, {'H', 0x00,0x00,0x30}},
        { 27, {'H', 0x00,0x10,0x10}},
        {  2, {'H', 0x00,0x10,0x10}},
        {  7, {'H', 0x00,0x00,0x20}},
        { 10, {'H', 0x00,0x00,0x40}},
        { 10, {'H', 0x00,0x00,0x40}},
        { 10, {'H', 0x00,0x00,0x20}},
        { 50, {'h', 0x0a,0xff,0xff}}, // set orange
        {  1, {'f',   40,0x00,0x00}}, // set color_step (fade speed) 
        {  5, {'H', 0x00,0x00,0xff}},
        {  1, {'H', 0x00,0x00,0x40}},
        {  1, {'H', 0x00,0x00,0x10}},
        {  5, {'H', 0x00,0x00,0x40}},
        {  5, {'H', 0x00,0x00,0x30}},
    }
};

// virtual water
const script fl_script_water PROGMEM = { 
    16, // number of lines
    0,  // number of repeats
    {
        {  1, {'f',   10,0x00,0x00}}, // set color_step (fade speed) 
        { 20, {'h',  140,0xff,0xff}}, // set blue
        {  2, {'H', 0x05,0x00,0x30}},
        {  2, {'H', 0x05,0x00,0x10}},
        {  2, {'H', 0x05,0x00,0x10}},
        {  7, {'H', 0x05,0x00,0x20}},
        { 10, {'H', 0x05,0x00,0x40}},
        { 10, {'H', 0x15,0x00,0x40}},
        { 10, {'H', 0x05,0x00,0x20}},
        { 20, {'h',  160,0xff,0xff}}, // set blue
        {  1, {'f',   20,0x00,0x00}}, // set color_step (fade speed) 
        {  5, {'H', 0x05,0x00,0x40}},
        {  1, {'H', 0x05,0x00,0x40}},
        {  1, {'H', 0x05,0x00,0x10}},
        {  5, {'H', 0x05,0x00,0x20}},
        {  5, {'H', 0x05,0x00,0x30}},
    }
};

// old neon
const script fl_script_oldneon PROGMEM = { 
    16, // number of lines
    0,  // number of repeats
    {
        {  1, {'f',   10,0x00,0x00}}, // set color_step (fade speed) 
        { 20, {'h',   10,0xff,0xff}}, // set reddish orange
        {  2, {'H', 0x05,0x00,0x20}},
        {  2, {'H', 0x05,0x00,0x10}},
        {  2, {'H', 0x05,0x00,0x10}},
        {  7, {'H', 0x05,0x00,0x20}},
        { 10, {'H', 0x05,0x00,0x40}},
        { 10, {'H', 0x15,0x00,0x40}},
        { 10, {'H', 0x05,0x00,0x20}},
        { 20, {'h',   14,0xff,0xff}}, // set reddish orange
        {  1, {'f',   30,0x00,0x00}}, // set color_step (fade speed) 
        {  5, {'H', 0x05,0x00,0xff}},
        {  1, {'H', 0x05,0x00,0x40}},
        {  1, {'H', 0x05,0x00,0x10}},
        {  5, {'H', 0x05,0x00,0x20}},
        {  5, {'H', 0x05,0x00,0x30}},
    }
};

// "the seasons" (cycle)
const script fl_script_seasons PROGMEM = {
    9, // number of lines
    0,  // number of repeats
    {
        {  1, {'f',    4,0x00,0x00}}, // set color_step (fade speed)
        {100, {'h',   70,0xff,0xff}}, // set green/yellow
        { 50, {'H',   10,0x00,0x00}}, // set green/yellow
        {100, {'h',  128,0xff,0xff}}, // set blue/green
        { 50, {'H',   10,0x00,0x00}}, // set blue/green
        {100, {'h',   20,0xff,0xff}}, // set orange/red
        { 50, {'H',   10,0x00,0x00}}, // set orange/red
        {100, {'h',  200,0x40,0xff}}, // set white/blue
        { 50, {'H',   10,0x00,0x00}}, // set white
    }
};

// "thunderstom"  (blues & purples, flashes of white)
const script fl_script_thunderstorm PROGMEM = {
    10, // number of lines
    0,  // number of repeats
    {
        {  1, {'f',    1,0x00,0x00}}, // set color_step (fade speed) 
        {100, {'h',  180,0xff,0x20}}, //
        { 20, {'H',    0,0x10,0x10}}, // randomize a bit
        {100, {'h',  175,0xff,0x20}}, // set dark blueish purple
        {  1, {'f',  200,0x00,0x00}}, // set fast fade speed 
        {  2, {'h',  188,0x00,0xff}}, // white (no saturation)
        {  2, {'h',  178,0x00,0x00}}, // black (no brightness)
        {  4, {'h',  188,0x00,0xff}}, // white (no saturation)
        {  1, {'f',   30,0x00,0x00}}, // 
        { 40, {'h',  172,0xff,0x10}}, // 
    }
};

// stop light
const script fl_script_stoplight PROGMEM = { 
    4, // number of lines
    0,  // number of repeats
    {
        {  1, {'f', 100,0x00,0x00}},  // set color_step (fade speed) 
        {100, {'h',   0,0xff,0xff}},  // set red
        {100, {'h',  90,0xff,0xff}},  // set 'green' (really teal)
        { 30, {'h',  48,0xff,0xff}},  // set yellow
    }
};

// morse code  - SOS
const script fl_script_morseSOS PROGMEM = { 
    17,  // number of lines
    0,  // number of repeats
    {
        { 1,  {'f',   100,0x00,0x00}}, // set color_step (fade speed) 
        { 5,  {'c',  0xff,0xff,0xff}}, 
        { 5,  {'c',  0x00,0x00,0x00}}, 
        { 5,  {'c',  0xff,0xff,0xff}}, 
        { 5,  {'c',  0x00,0x00,0x00}}, 
        { 5,  {'c',  0xff,0xff,0xff}}, 
        {10,  {'c',  0x00,0x00,0x00}}, 
        {10,  {'c',  0xff,0xff,0xff}}, 
        {10,  {'c',  0x00,0x00,0x00}}, 
        {10,  {'c',  0xff,0xff,0xff}}, 
        {10,  {'c',  0x00,0x00,0x00}}, 
        { 5,  {'c',  0xff,0xff,0xff}}, 
        { 5,  {'c',  0x00,0x00,0x00}}, 
        { 5,  {'c',  0xff,0xff,0xff}}, 
        { 5,  {'c',  0x00,0x00,0x00}}, 
        { 5,  {'c',  0xff,0xff,0xff}}, 
        {20,  {'c',  0x00,0x00,0x00}}, 
    }
};


const script* fl_scripts[] PROGMEM = {
    &fl_script_rgb,                    // 1
    &fl_script_blink_white,            // 2
    &fl_script_blink_red,              // 3
    &fl_script_blink_green,            // 4
    &fl_script_blink_blue,             // 5
    &fl_script_blink_cyan,             // 6
    &fl_script_blink_magenta,          // 7
    &fl_script_blink_yellow,           // 8
    &fl_script_black,                  // 9
    &fl_script_hue_cycle,              // 10
    &fl_script_randmood,               // 11
    &fl_script_candle,                 // 12
    &fl_script_water,                  // 13
    &fl_script_oldneon,                // 14
    &fl_script_seasons,                // 15
    &fl_script_thunderstorm,           // 16
    &fl_script_stoplight,              // 17
    &fl_script_morseSOS,               // 18
};
#else
const script* fl_scripts[] PROGMEM = {};
#endif

// eeprom begin: muncha buncha eeprom
uint8_t  ee_i2c_addr         EEMEM = I2C_ADDR;
uint8_t  ee_boot_mode        EEMEM = BOOT_PLAY_SCRIPT;
uint8_t  ee_boot_script_id   EEMEM = 0x00;
uint8_t  ee_boot_reps        EEMEM = 0x00;
uint8_t  ee_boot_fadespeed   EEMEM = 0x08;
uint8_t  ee_boot_timeadj     EEMEM = 0x00;
uint8_t  ee_unused2          EEMEM = 0xDA;

script ee_script  EEMEM = {
    6, // number of seq_lines
    0, // number of repeats, also acts as boot repeats?
    {  // dur, cmd,  arg1,arg2,arg3
        {  1, {'f',   10,0x00,0x00}}, // set color_step (fade speed) to 15
        {100, {'c', 0xff,0xff,0xff}},
        { 50, {'c', 0xff,0x00,0x00}},
        { 50, {'c', 0x00,0xff,0x00}},
        { 50, {'c', 0x00,0x00,0xff}},
        { 50, {'c', 0x00,0x00,0x00}}
    }
};

/*
script ee_script  EEMEM = {
   12, // number of seq_lines
    0, // number of repeats, also acts as boot repeats?
    {  // dur, cmd,  arg1,arg2,arg3
        {  0, {'f',  100,0x00,0x00}}, // set color_step (fade speed) to 15
        {  0, {'s',  'o',   0,0x00}},  // send stop
        {  0, {'s',  'f', 100,0x00}},  // send fadespeed
        //{  0, {'s',  't',  20,0x00}},  // send time adjust
        {  0, {'c', 0x33,0x33,0x33}},  // white
        { 30, {'s',  'p',   2,0x00}},  // send play white
        {  0, {'c', 0x33,0x00,0x00}},  // red
        { 30, {'s',  'p',   3,0x00}},  // send play red flash
        {  0, {'c', 0x00,0x33,0x00}},  // grn
        { 30, {'s',  'p',   4,0x00}},  // send play grn flash
        {  0, {'c', 0x00,0x00,0x33}},  // blu
        { 30, {'s',  'p',   5,0x00}},  // send play blu flash
        {  0, {'s',  'p',   9,0x00}},  // send play black
    }
};
*/
/*
script ee_script  EEMEM = {
    5, // number of seq_lines
    0, // number of repeats, also acts as boot repeats?
    {  // dur, cmd,  arg1,arg2,arg3
        { 0, {'c',  0x66,0x66,0x66}},
        { 0, {'s',  'f',  10,   0}},
        {50, {'s',  'p',   0,   5}},  
        {50, {'s',  'p',   0,   4}},
        {50, {'s',  'p',   0,   3}},
        {50, {'s',  'p',   0,   2}},
    }
};
*/
/*
script ee_script  EEMEM = {
    9, // number of seq_lines
    0, // number of repeats, also acts as boot repeats?
    {  // dur, cmd,  arg1,arg2,arg3
        { 0, {'s',  'f',  10,   0}},
        {50, {'s',  'p',   0,   5}},  
        { 0, {'c', 0x00,0x00,0x66}},
        {50, {'s',  'p',   0,   4}},
        { 0, {'c', 0x00,0x66,0x00}},
        {50, {'s',  'p',   0,   3}},
        { 0, {'c', 0x66,0x00,0x00}},
        {50, {'s',  'p',   0,   2}},
        { 0, {'c', 0x66,0x66,0x66}},
    }
};
*/
/*
script ee_script  EEMEM = {
    1, // number of seq_lines
    0, // number of repeats, also acts as boot repeats?
    {
        {1, {'k', 0xff,0xff,0xff}}, // inputs 0,1,2 control R,G,B
    }
};
*/
/*
// set a color, then let knob 3 control brightness
script ee_script  EEMEM = {
    3, // number of seq_lines
    0, // number of repeats, also acts as boot repeats?
    {  // dur, cmd,  arg1,arg2,arg3
        {  1, {'h', 0x15,0xff,0xff}}, // set HSB color
        {  1, {'K', 0x00,0x00,0xff}}, // only input 3, just brightness
        {  1, {'j',   -1,   0,   0}}, // jump back to 'K'nob
    }
};
*/

/*
script ee_script  EEMEM = {
    3, // number of seq_lines
    0, // number of repeats
    {  // dur, cmd,  arg1,arg2,arg3
        {  1, {'h', 0x80,0xff,0xff}}, // set HSB 
        {  1, {'k', 0x00,0x00,0xff}}, // only let input 3 control brightness
        {  1, {'i',    1,0xA0,   2}}, // if input 1 > 0xA0, jump +2
        {  1, {'j',   -2,   0,   0}}, // jump -2 (back to 'k'nob)
        {  1, {'c', 0xff,0x00,0x00}}, // red
    }
};
*/
/*
// display constant red, when input 1 goes > A0, do a little glimmer,
// then go back to being constant red
script ee_script  EEMEM = {
    8, // number of seq_lines
    0, // number of repeats
    {  // dur, cmd,  arg1,arg2,arg3
        {  1, {'f',   40,0x00,0x00}}, // set color_step (fade speed) to 40
        {  1, {'c', 0xff,0x00,0x00}}, // red
        {  1, {'i',    1,0xA0,  -1}}, // on input 1, jump -1 if > A0
        { 10, {'c', 0xff,0xff,0xff}}, // only do this if input is grounded
        {  5, {'c', 0x33,0x00,0xff}}, // blueish purple
        {  2, {'c', 0xff,0xff,0xff}}, // white
        {  5, {'c', 0x00,0x00,0xff}}, // blue
        {  7, {'c', 0xff,0xff,0xff}}, // white
    }
};
*/

/*
// flash red repeatedly, unless input 0 is > A0, 
// then flash white/blue repeatedly
// once input 0 returns to < A0, return to flashing red
script ee_script  EEMEM = {
    11,// number of seq_lines
    0, // number of repeats
    {  // dur, cmd,  arg1,arg2,arg3
        {  1, {'f',   40,0x00,0x00}}, // set color_step (fade speed) to 40
        {  5, {'c', 0xff,0x00,0x00}}, 
        {  5, {'c', 0x00,0x00,0x00}}, 
        {  1, {'i', 0x00,0xA0,0x02}}, // on input 1, jump +2 if > A0
        {  1, {'j',   -3,   0,   0}}, // jump -3
        { 10, {'c', 0xff,0xff,0xff}},
        {  5, {'c', 0x33,0x00,0xff}},
        {  2, {'c', 0xff,0xff,0xff}},
        {  5, {'c', 0x00,0x00,0xff}},
        {  7, {'c', 0xff,0xff,0xff}},
        {  1, {'i', 0x00,0xA0,  -5}},  // if >0 jump back to start of 2nd seq
    }
};
*/
/*
script ee_script  EEMEM = {
    11,// number of seq_lines
    0, // number of repeats
    {  // dur, cmd,  arg1,arg2,arg3
        {  1, {'f',   40,0x00,0x00}}, // set color_step (fade speed) to 40
        {  5, {'c', 0xff,0x00,0x00}}, 
        {  5, {'c', 0x00,0x00,0x00}}, 
        {  1, {'i', 0x00,0xA0,0x02}}, // on input 1, jump +2 if > A0
        {  1, {'j',   -3,   0,   0}}, // jump -3
        { 10, {'c', 0xff,0xff,0xff}},
        {  5, {'c', 0x33,0x00,0xff}},
        {  2, {'c', 0xff,0xff,0xff}},
        {  5, {'c', 0x00,0x00,0xff}},
        {  7, {'c', 0xff,0xff,0xff}},
        {  1, {'i', 0x00,0xA0,  -5}},  // if >0 jump back to start of 2nd seq
    }
};
*/
// eeprom end
