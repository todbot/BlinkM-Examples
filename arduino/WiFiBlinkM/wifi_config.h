// BEGIN Wireless configuration parameters ----------------------------------
// Edit these to match your network
// You must pick an IP address by hand


// crashspace network
const prog_char ssid[] PROGMEM = {"CrashSpaceTW"};    // max 32 bytes
unsigned char local_ip[]    = {172,16,16,182}; // IP address of WiShield
unsigned char gateway_ip[]  = {172,16,16,1};   // router/gateway IP address
unsigned char subnet_mask[] = {255,255,255,0};  // subnet mask for network
// set security type
unsigned char security_type = 0;    // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2
// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"blahblah"};  // max 64 chars

/*
// crashspace network
const prog_char ssid[] PROGMEM = {"CrashSpaceDSL"};    // max 32 bytes
unsigned char local_ip[]    = {192,168,1,182}; // IP address of WiShield
unsigned char gateway_ip[]  = {192,168,1,254};   // router/gateway IP address
unsigned char subnet_mask[] = {255,255,255,0};  // subnet mask for network
// set security type
unsigned char security_type = 0;    // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2
// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"blahblah"};  // max 64 chars
*/
/*
// alex's network
const prog_char ssid[] PROGMEM = {"The First"};    // max 32 bytes
unsigned char local_ip[]    = {192,168,1,110}; // IP address of WiShield
unsigned char gateway_ip[]  = {192,168,1,1};   // router/gateway IP address
unsigned char subnet_mask[] = {255,255,255,0};  // subnet mask for network
// set security type
unsigned char security_type = 2;    // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2
// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"C0183rTn@t10N"};  // max 64 chars
*/
/*
// tod's network
const prog_char ssid[] PROGMEM = {"todbot"};    // max 32 bytes
unsigned char local_ip[]    = {192,168,42,182}; // IP address of WiShield
unsigned char gateway_ip[]  = {192,168,42,1};   // router/gateway IP address
unsigned char subnet_mask[] = {255,255,255,0};  // subnet mask for network
// set security type
unsigned char security_type = 0;    // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2
// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"C0183rTn@t10N"};  // max 64 chars
*/

// WEP 128-bit keys
// sample HEX keys
prog_uchar wep_keys[] PROGMEM = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, // Key 0
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Key 1
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Key 2
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // Key 3
};
#define WIRELESS_MODE_INFRA 1
#define WIRELESS_MODE_ADHOC 2
// setup the wireless mode: 
// infrastructure - connect to AP,  adhoc - connect to another WiFi device
unsigned char wireless_mode = WIRELESS_MODE_INFRA;

unsigned char ssid_len;
unsigned char security_passphrase_len;
// END   Wireless configuration parameters ----------------------------------
