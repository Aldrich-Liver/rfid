/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ui_config.h
 *
 *  Notes:
 *
 ******************************************************************************/

#ifndef __UI_CONFIG_H__
#define __UI_CONFIG_H__

#define ZT_UI_HOME_COLOR_BTN_BACKGROUND                            0xc3
#define ZT_UI_HOME_COLOR_BTN_SHADOW                                0x8c
#define ZT_UI_HOME_BTN_CORNER_RADIUS                               0
#define ZT_UI_HOME_BTN_SHADOW_SIZE                                 3
#define ZT_UI_HOME_BTN_FONT_SIZE                                   18.0
#define ZT_UI_HOME_BTN_FONT_COLOR
#define ZT_UI_HOME_BTN_FONT_NAME                                   @"System"

#define ZT_UI_RAPID_READ_COLOR_LBL_BACKGROUND                      0xcc
#define ZT_UI_RAPID_READ_CORNER_RADIUS_BIG                         15
#define ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL                       5
#define ZT_UI_RAPID_READ_FONT_SZ_LBL                               15.0

#define ZT_UI_INVENTORY_COLOR_LBL_HEADER                           0x66
#define ZT_UI_INVENTORY_COLOR_LBL_HEADER_SHADOW                    0xc9
#define ZT_UI_INVENTORY_COLOR_SEARCH_FIELD                         0x99
#define ZT_UI_INVENTORY_FONT_SZ_SMALL                              10.0
#define ZT_UI_INVENTORY_FONT_SZ_BIG                                19.0
#define ZT_UI_INVENTORY_FONT_SZ_MEDIUM                             14.0
#define ZT_UI_INVENTORY_FONT_SZ_BUTTON                             23.0

#define ZT_UI_CELL_TAG_FONT_SZ_BIG                                 17.0
#define ZT_UI_CELL_TAG_FONT_SZ_MEDIUM                              15.0
#define ZT_UI_CELL_TAG_FONT_SZ_SMALL                               11.0
#define ZT_UI_CELL_TAG_INDENT_EXT                                  10.0
#define ZT_UI_CELL_TAG_INDENT_INT_BIG                              8.0
#define ZT_UI_CELL_TAG_INDENT_INT_SMALL                            2.0

#define ZT_UI_CELL_CUSTOM_FONT_SZ_TEXT_FIELD                       17.0
#define ZT_UI_CELL_CUSTOM_FONT_SZ_BIG                              17.0
#define ZT_UI_CELL_CUSTOM_FONT_SZ_SMALL                            14.0
#define ZT_UI_CELL_CUSTOM_INDENT_EXT                               10.0
#define ZT_UI_CELL_CUSTOM_INDENT_INT_SMALL                         0.0
#define ZT_UI_CELL_CUSTOM_INDENT_INT_BIG                           10.0
#define ZT_UI_CELL_CUSTOM_IMAGE_SZ                                 25.0

#define ZT_UI_LOCATE_TAG_INDENT_EXT                                10.0
#define ZT_UI_LOCATE_TAG_FONT_SZ_SMALL                             12.0
#define ZT_UI_LOCATE_TAG_FONT_SZ_BIG                               20.0
#define ZT_UI_LOCATE_TAG_FONT_SZ_MEDIUM                            17.0
#define ZT_UI_LOCATE_TAG_FONT_SZ_BUTTON                            23.0
#define ZT_UI_LOCATE_TAG_COLOR_BACKGROUND                          0xcc
#define ZT_UI_LOCATE_TAG_COLOR_LEVEL_RED                           42.0
#define ZT_UI_LOCATE_TAG_COLOR_LEVEL_GREEN                         127.0
#define ZT_UI_LOCATE_TAG_COLOR_LEVEL_BLUE                          255.0
#define ZT_UI_LOCATE_TAG_COLOR_LINE_RED                            0x3f
#define ZT_UI_LOCATE_TAG_COLOR_LINE_GREEN                          0x9f
#define ZT_UI_LOCATE_TAG_COLOR_LINE_BLUE                           0x9f
#define ZT_UI_LOCATE_TAG_INDICATOR_CORNER_RADIUS                   2

#define ZT_UI_ACCESS_FONT_SZ_SMALL                                 12.0
#define ZT_UI_ACCESS_FONT_SZ_BIG                                   20.0
#define ZT_UI_ACCESS_FONT_SZ_MEDIUM                                17.0
#define ZT_UI_ACCESS_FONT_SZ_BUTTON                                23.0
#define ZT_UI_ACCESS_INDENT                                        10.0

#define ZT_UI_FILTER_FONT_SZ_SMALL                                 12.0
#define ZT_UI_FILTER_FONT_SZ_BIG                                   20.0
#define ZT_UI_FILTER_FONT_SZ_MEDIUM                                17.0
#define ZT_UI_FILTER_FONT_SZ_BUTTON                                23.0
#define ZT_UI_FILTER_INDENT                                        10.0

#define ZT_UI_BATTERY_FONT_SZ_MEDIUM                               17.0
#define ZT_UI_BATTERY_FONT_SZ_BIG                                  23.0

#define ZT_UI_ABOUT_FONT_SZ_MEDIUM                                 16.0
#define ZT_UI_ABOUT_FONT_SZ_BIG                                    20.0

#define ZT_UI_ANTENNA_TARI_WIDTH                                   40.0

#define ZT_STR_SETTINGS_READER_LIST                                @"Readers List"
#define ZT_STR_SETTINGS_CONNECTION                                 @"Application"
#define ZT_STR_SETTINGS_ANTENNA                                    @"Antenna"
#define ZT_STR_SETTINGS_START_STOP_TRIGGER                         @"Start\\Stop Triggers"
#define ZT_STR_SETTINGS_SINGULATION_CONTROL                        @"Singulation Control"
#define ZT_STR_SETTINGS_REGULATORY                                 @"Regulatory"
#define ZT_STR_SETTINGS_BEEPER                                     @"Beeper"
#define ZT_STR_SETTINGS_SAVE                                       @"Save Configuration"
#define ZT_STR_SETTINGS_BATTERY                                    @"Battery"
#define ZT_STR_SETTINGS_TAG_REPORT                                 @"Tag Reporting"
#define ZT_STR_SETTINGS_PWR_MANAGEMENT                             @"Power Optimization"


#define ZT_STR_SETTINGS_SECTION_READER_LIST                        @"Readers List"
#define ZT_STR_SETTINGS_SECTION_APPLICATION                        @"Application"
#define ZT_STR_SETTINGS_SECTION_PROFILE                            @"Profiles"
#define ZT_STR_SETTINGS_SECTION_ADVANCED_READER_OPTIONS            @"Advanced Reader Options"
#define ZT_STR_SETTINGS_SECTION_REGULATORY                         @"Regulatory"
#define ZT_STR_SETTINGS_SECTION_BATTERY                            @"Battery"
#define ZT_STR_SETTINGS_SECTION_BEEPER                             @"Beeper"
#define ZT_STR_SETTINGS_SECTION_LED                                @"LED"
#define ZT_STR_SETTINGS_SECTION_SCANNER                            @"Scanner Settings"
#define ZT_STR_SETTINGS_SECTION_FIRMWARE_UPDATE                    @"Firmware Update"
#define ZT_STR_SETTINGS_SECTION_TRIGGER_MAPPING                    @"Trigger Mapping"
#define ZT_STR_SETTINGS_SECTION_DEVICE_INFORMATION                 @"Device Information"
#define ZT_STR_SETTINGS_SECTION_SHARE_FILE                         @"Share File"
#define ZT_STR_SETTINGS_SECTION_FACTORY_RESET                      @"Factory Reset"
#define ZT_STR_SETTINGS_SECTION_PRO_CLIP                           @"Pro Clip"
#define ZT_STR_SETTINGS_SECTION_GET_BATTERY_STATUS                 @"Battery Statistics"
#define ZT_STR_SETTINGS_SECTION_WIFI                               @"WiFi"
#define ZT_STR_SETTINGS_SECTION_CERTIFICATES                       @"Certificates"
#define ZT_STR_SETTINGS_SECTION_ENDPOINTCONFIG                     @"Endpoint Settings"
#define ZT_STR_SETTINGS_SECTION_ADMINLOGIN                         @"Admin Login"
#define ZT_STR_SETTINGS_SECTION_IMPINJ                             @"Impinj Tag Settings"

#define ZT_STR_SETTINGS_PWR_MANAGEMENT_DYNAMIC_POWER               @"Dynamic Power"

#define ZT_STR_SETTINGS_CONNECTION_AUTO_RECONNECT                  @"Auto Reconnect Reader"
#define ZT_STR_SETTINGS_CONNECTION_NOTIFICATION_AVAILABLE          @"Reader Available"
#define ZT_STR_SETTINGS_CONNECTION_NOTIFICATION_ACTIVE             @"Reader Connection"
#define ZT_STR_SETTINGS_CONNECTION_NOTIFICAtiON_BATTERY            @"Reader Battery Status"
#define ZT_STR_SETTINGS_CONNECTION_DATA_EXPORT                     @"Export Data"
#define ZT_STR_SETTINGS_CONNECTION_TAG_LIST                        @"Tag List Match Mode"
#define ZT_STR_SETTINGS_CONNECTION_FRIENDLY_NAMES                  @"Show Friendly Names"
#define ZT_STR_SETTINGS_CONNECTION_ASCII_MODE                      @"Enable ASCII Mode"
#define ZT_STR_SETTINGS_CONNECTION_HEADER_CONNECTION               @"Reader Connection Settings"
#define ZT_STR_SETTINGS_CONNECTION_HEADER_NOTIFICATION             @"Notification Settings"
#define ZT_STR_SETTINGS_CONNECTION_HEADER_DATA_EXPORT              @"Data Export Settings"
#define ZT_STR_SETTINGS_CONNECTION_HEADER_MATCH_MODE               @"Match Mode"
#define ZT_STR_SETTINGS_CONNECTION_HEADER_GLOBAL_SETTINGS          @"Global Settings"
#define ZT_STR_SETTINGS_CONNECTION_SGTIN96_MODE                    @"SGTIN-96 Mode"

#define ZT_STR_SETTINGS_ANTENNA_POWER_LEVEL                        @"Power level(dbm)"
#define ZT_STR_SETTINGS_ANTENNA_LINK_PROFILE                       @"Link profile"
#define ZT_STR_SETTINGS_ANTENNA_TARI                               @"Tari"
#define ZT_STR_SETTINGS_ANTENNA_PIE                                @"PIE"
#define ZT_STR_SETTINGS_ANTENNA_DO_SELECT                          @"Do Select"

#define ZT_BUTTON_RAPID_READ                                       1
#define ZT_STR_BUTTON_RAPID_READ                                   @"Rapid Read"
#define ZT_BUTTON_INVENTORY                                        2
#define ZT_STR_BUTTON_INVENTORY                                    @"Inventory"
#define ZT_BUTTON_SETTINGS                                         3
#define ZT_STR_BUTTON_SETTING                                      @"Settings"
#define ZT_BUTTON_LOCATE_TAG                                       4
#define ZT_STR_BUTTON_LOCATE_TAG                                   @"Locate Tag"
#define ZT_BUTTON_FILTER                                           5
#define ZT_STR_BUTTON_FILTER                                       @"Pre Filters"
#define ZT_BUTTON_ACCESS                                           6
#define ZT_STR_BUTTON_ACCESS                                       @"Access Control"

#define ZT_WARNING_NO_READER                                       @"No Active Reader"
#define ZT_WARNING_NO_MATCH                                        @"No Match Found"


#define ZT_TAGREPORT_BATCHMODE_ENABLE                              @"ENABLE"
#define ZT_TAGREPORT_BATCHMODE_AUTO                                @"AUTO"
#define ZT_TAGREPORT_BATCHMODE_DISABLE                             @"DISABLE"


#define CELL_IMAGE_PROFILE                     @"profiles.png"
#define CELL_IMAGE_BATTERY                     @"settings_battery.png"
#define CELL_IMAGE_BEEPER                      @"settings_beeper.png"
#define CELL_IMAGE_LED                         @"settings_led.png"
#define CELL_IMAGE_APPLICATION                 @"settings_management.png"
#define CELL_FIRMWARE_UPDATE                   @"firmware"
#define CELL_SHARE                             @"share"
#define CELL_FACTORY_RESET                     @"reload_icon"
#define CELL_PRO_CLIP                          @"Adapter"
#define CELL_IMAGE_WIFI                        @"settings_wifi"
#define CELL_IMAGE_CERTIFICATES                @"certificates_icon"


#define CELL_GET_BATTERY_STATUS                 @"BatteryStatus"

#define CELL_TRIGGER                           @"rfid_settings"
#define CELL_IMAGE_READER_LIST                 @"settings_readers_list.png"
#define CELL_IMAGE_REGULATORY                  @"settings_regulatory.png"
#define CELL_IMAGE_ADVANCED_READER_OPTIONS     @"settings_rfid_accessory.png"
#define CELL_IMAGE_PWR_MANAGEMENT_ON           @"title_pwr_on.png"
#define CELL_IMAGE_PWR_MANAGEMENT_OFF          @"title_pwr_off.png"
#define CELL_IMAGE_ADVANCE_SCANNER_OPTION      @"tab_barcode_icon.png"
#define CELL_IMAGE_DEVICE_INFORMATION            @"asset_info.png"

#define SAVE_ANTENNA_SETTINGS                  @"Saving antenna settings"
#define SAVE_SINGULATION_SETTINGS              @"Saving singulation settings"
#define SAVE_START_STOP_TRIGGER_SETTINGS       @"Saving start\\stop trigger settings"
#define SAVE_TAG_REPORT_SETTINGS               @"Saving tag report settings"
#define SAVE_POWER_MANAGEMENT_SETTINGS         @"Saving power management settings"
#define SAVE_REGULATORY_SETTINGS               @"Saving regulatory settings"
#define SAVE_BEEPER_SETTINGS                   @"Saving beeper settings"
#define SAVE_PROFILE_SETTINGS                  @"Saving profile settings"

#define DYNAMIC_POWER_ENABLE                   @"currentDpoEnable"
#define STORY_BOARD_NAME                       @"RFIDDemoApp"
#define ANTENNA_STORY_BOARD_ID                 @"ID_ANTENNA_SETTINGS_VC"
#define SINGULATION_STORY_BOARD_ID             @"ID_SINGULATION_SETTINGS_VC"
#define TRIGGER_STORY_BOARD_ID                 @"ID_TRIGGER_SETTINGS_VC"
#define TAG_REPORT_STORY_BOARD_ID              @"ID_TAG_REPORT_SETTINGS_VC"
#define SAVE_SETTINGS_STORY_BOARD_ID           @"ID_SAVE_SETTINGS_VC"
#define POWER_MANAGEMENT_STORY_BOARD_ID        @"ID_POWER_MANAGEMENT_SETTINGS_VC"
#define READER_LIST_STORY_BOARD_ID             @"ID_READER_LIST_VC"
#define APPLICATION_STORY_BOARD_ID             @"ID_CONNECTION_SETTINGS_VC"
#define PROFILE_STORY_BOARD_ID                 @"ID_PROFILE_SETTING_VC"
#define ADVANCED_OPTIONS_STORY_BOARD_ID        @"ID_ADVANCED_OPTIONS_SETTING_VC"
#define REGULATORY_STORY_BOARD_ID              @"ID_REGULATORY_SETTINGS_VC"
#define BATTERY_STORY_BOARD_ID                 @"ID_BATTERY_STATUS_VC"
#define BEPPER_SETTINGS_STORY_BOARD_ID         @"ID_BEEPER_SETTINGS_VC"
#define SCAN_PAIR_STORY_BOARD_ID               @"ID_SCAN_PAIR_VC"
#define HELP_STORY_BOARD_ID                    @"ID_HELP_VC"
#define STORY_BOARD_BARCODE                    @"BarcodeDataView"
#define BARCODE_FULL_VIEW_STORY_BOARD_ID       @"ID_BARCODE_FULL_ID"
#define FACTORY_RESET_BOARD_ID                 @"FACTORY_RESET_BOARD_ID"
#define PRO_CLIP_BOARD_ID                      @"PRO_CLIP_BOARD_ID"
#define BATTERY_STATUS_BOARD_ID                @"BATTERY_STATUS_BOARD_ID"
#define ENDPOINT_CONFIG_STORY_BOARD_ID         @"ID_ENDPOINT_CONFIG_VC"

// About page strings
#define ABOUT_APPLICATION_VERSION               @"Application version"
#define ABOUT_RFID_READER                       @"RFID Reader"
#define ABOUT_MODULE_VERSION                    @"Module version"
#define ABOUT_RADIO_VERSION                     @"Radio version"
#define ABOUT_COPY_RIGHT                        @"Copyright"

// Start and Stop icons for scanner start and stop action.
#define START_SCAN_ICON                         @"start_scan_icon"
#define STOP_SCAN_ICON                          @"stop_scan_icon"

// Scan and pair icons
#define SCAN_PAIR_ICON                          @"scan_pair_icon"
#define SELECT_ICON                             @"select_icon"
#define HELP_ICON                               @"help_icon"


// Scan and pair title
#define SCAN_PAIR_TITLE                         @"Scan and Pair RFD8500"
#define SCAN_BARCODE                            @"Scan barcode or enter value"
#define SCAN_PLACE_HOLDER                       @"S/N or BT MAC"
#define SCAN_PAIR_UNPAIR_TEXT                   @"PAIR AND UNPAIR"
#define SCAN_PAIRED_READERS                     @"Paired Readers"
#define OPEN_SETTINGS_STRING                    @"App-Prefs:root=General"
#define BARCODE_RFID_IN_PROGRESS                    @"Getting batched tags: operation not allowed"

// Help screen
#define HELP_TITLE                              @"HELP"
#define HELP_DESCRIPTION_TITLE                  @"1. Turn the RFD8500 on and ensure Bluetooth is enabled.The RFD8500 is discoverable over Bluetooth for 40 seconds after start up. After that time Bluetooth suspends and is no longer discoverable. To make discoverable again, press the Bluetooth button, located on the side of RFD8500.\n\n2. Enable Bluetooth on the device.\n\n3. The device will discover the RFD8500 and display it on the Bluetooth Devices list.\n\n4. Tap the RFD8500 to initiate pairing from the Bluetooth Devices list.\n\n5. Press the RFD8500 trigger to complete pairing when the Bluetooth LED starts flashing fast."

// RFID Theme Color
#define THEME_COLOR                             @"rfid_theme_color"
#define THEME_BLUE_COLOR [UIColor colorWithRed:0.0/255.0 green:124.0/255.0 blue:196.0/255.0 alpha:1.0];

// RFID Locate tag border width
#define BORDER_WIDTH                            1.0
#define ZT_ACCESS_CONTROL_FIELD_WIDTH            40

// RFID Beeper text
#define SLED_BEEPER_TEXT                        @"Sled Beeper"
#define HOST_BEEPER_TEXT                        @"Host Beeper"
#define BEEPER_VOLUME_TEXT                      @"Volume"

// RFID Locate tag placeholder
#define LOCATE_TAG_PLACE_HOLDER                 @"Tag Pattern"
#define TAG_INPUT_TEXT_LOCATION                 CGRectMake(10,0,10,30)

// RFID Profiles Viewcontroller
#define PROFILE_FASTEST_READ                    @"Fastest Read"
#define PROFILE_CYCLE_COUNT                     @"Cycle Count"
#define PROFILE_DENSE_READERS                   @"Dense Readers"
#define PROFILE_OPTIMAL_BATTERY                 @"Optimal Battery"
#define PROFILE_BALANCED_PERFORMANCE            @"Balanced Performance"
#define PROFILE_USER_DEFINED                    @"User Defined"
#define PROFILE_READER_DEFINED                  @"Reader Defined"
#define FASTEST_READ_SUB_TITLE                  @"Read as many tags as fast as possible"
#define CYCLE_COUNT_SUB_TITLE                   @"Read as many unique tags possible"
#define DENSE_READERS_SUB_TITLE                 @"Use when multiple readers in close proximity"
#define OPTIMAL_BATTERY_SUB_TITLE               @"Gives best battery life"
#define BALANCED_PERFORMANCE_SUB_TITLE          @"Maintains balance between performance and battery life"
#define USER_DEFINED_SUB_TITLE                  @"Custom profile used for custom requirement"
#define READER_DEFINED_SUB_TITLE                @"Multiple reader configurations application does not configure the reader after connection"
#define PROFILE_POWER_LEVEL                     @"Power Level (tens of dbm)"
#define PROFILE_LINK_PROFILE                    @"Link Profile"
#define PROFILE_SESSION                         @"Session"
#define PROFILE_DYNAMIC_POWER                   @"Dynamic Power"
#define PROFILE_LINK_PICKER                     @"LinkPicker"
#define PROFILE_SESSION_PICKER                  @"SessionPicker"

#define PROFILE_KEY_CONTENT                     @"content"
#define PROFILE_KEY_DETAILS                     @"details"
#define PROFILE_KEY_POWER                       @"power"
#define PROFILE_KEY_LINKPROFILE                 @"linkprofile"
#define PROFILE_KEY_SESSION                     @"session"
#define PROFILE_KEY_DYNAMICPOWER                @"dynamicpower"
#define PROFILE_KEY_CELL_SWITCH_ON              @"switchon"
#define PROFILE_KEY_ENABLED                     @"enabled"
#define DEFAULTS_KEY                            @"profileIndex"
#define ANTENNA_DEFAULTS_KEY                    @"profileUpdated"
#define USER_DEFINED_INDEX                      @"5"
#define READER_DEFINED_INDEX                    @"6"
#define CYCLE_COUNT_INDEX                       @"1"
#define USER_DEFINED_DIC_DEFAULTS_KEY           @"UserProfileDictionary"
#define ACTIVE_PROFILE_DIC_DEFAULTS_KEY         @"ActiveProfileDictionary"
#define FASTEST_PROFILE_DIC_DEFAULTS_KEY        @"FastestProfileDictionary"
#define LINKPROFILE_KEY                         @"linkprofileLocal"


// RFID Tag reporting
#define TAG_REPORT_TITLE                        @"Tag Reporting"
#define TAG_REPORTING_DATAFIELD                 @"Tag report data fields"
#define BATCH_MODE_SECTION                      @"Batch Mode Setings"
#define UNIQUE_TAG_SETTINGS                     @"Unique tag settings"
#define NXP_BRANDID_CHECK                       @"NXP BrandID Check"
#define BATCH_MODE                              @"BT Batchmode"
#define USB_BATCH_MODE                          @"USB Batchmode"
#define CHANNEL_INDEX                           @"Channel Index"
#define TAG_REPORT_PC                           @"PC"
#define TAG_REPORT_PHASE                        @"Phase"
#define TAG_REPORT_RSSI                         @"RSSI"
#define TAG_SEEN_COUNT                          @"Tag Seen Count"
#define REPORT_UNIQUE_TAGS                      @"Report unique tags"
#define CHECK_BRANDID                           @"Check BrandID"
#define BRANDID                                 @"Brand ID"
#define EPC_LENGTH                              @"EPC Length"

// RFID TAGReporting
#define SAMPLE_BRANDID                          @"AAAA"
#define SAMPLE_EPC_LENGTH                       @"12"
#define EPC_LENGTH_MAX_VALUE                    255
#define BRANDID_KEY_DEFAULTS                    @"BrandID"
#define EPCLENGTH_KEY_DEFAULTS                  @"EPCLength"
#define EPCLENGTH_OLD_KEY_DEFAULTS              @"EPCLengthOld"
#define BRANDIDCHECK_KEY_DEFAULTS               @"BrandIDCheck"
#define EMPTY_STRING                            @""
#define CHECK_BRAND_ID_VALUE_IS_CHANGED_KEY     @"NewBrandIDCheck"
#define EXISTING_BRAND_ID_VALUE_CHECK_KEY       @"LocalBrandIDCheck"
#define NXP_BRANDID_WARNING_MESSAGE             @"Warning"
#define NXP_BRANDID_OK_MESSAGE                  @"Ok"
#define NXP_BRANDID_MAX_LENGTH                  4
#define NXP_BRANDID_FAILED_SETTINGS             @"Failed to apply settings for BrandId"
#define NXP_BRANDID_SUCCESS_SETTINGS            @"Settings applied successfully"

// RFID PowerLevel static values
#define POWER_LEVEL_VALUE1                      @"300"
#define POWER_LEVEL_VALUE2                      @"240"
#define POWER_LEVEL_VALUE3                      @"270"

// RFID LinkProfile static values
#define LINK_PROFILE_AUTOMAC                    @"AUTOMAC"
#define LINK_PROFILE_FM0                        @"FM0"
#define LINK_PROFILE_M                          @"M"
#define LINK_PROFILE_K                          @"K"
#define LINK_PROFILE_MODULATION_2               2
#define LINK_PROFILE_MODULATION_4               4
#define LINK_PROFILE_MODULATION_8               8
#define LINK_PROFILE_MILLER_2                   2
#define LINK_PROFILE_MILLER_4                   4
#define LINK_PROFILE_MILLER_8                   8
#define LINK_PROFILE_MILLER_1                   1
#define LINK_PROFILE_TARI_668                   668
#define TARI_FIRST_INDEX                        0
#define PIE_FIRST_INDEX                         0
#define MIN_TARI_12500                          12500
#define STEP_TARI_6300                          6300
#define STEP_TARI_6300                          6300
#define ANTENNA_PAI_1500                        1500
#define MIN_TARI_25000                          25000
#define MIN_TARI_23000                          23000
#define MIN_TARI_18800                          18800
#define MIN_TARI_6250                           6250
#define MIN_TARI_668                            668

#define TARI_ARRAY_GENERAL                       [[NSArray alloc] initWithObjects:@"6250",@"12500",@"14600",@"16700",@"18800",@"20900",@"23000",@"25000", nil];
#define TARI_ARRAY_6250                           [[NSArray alloc] initWithObjects:@"6250", nil];
#define TARI_ARRAY_12500_25000                         [[NSArray alloc] initWithObjects:@"12500",@"14600",@"16700",@"18800",@"20900",@"23000",@"25000", nil];
#define TARI_ARRAY_668                          [[NSArray alloc] initWithObjects:@"668", nil];
#define TARI_ARRAY_18800_25000                  [[NSArray alloc] initWithObjects:@"18800",@"20900",@"23000",@"25000", nil];
#define TARI_ARRAY_12500_18800                        [[NSArray alloc] initWithObjects:@"12500",@"14600",@"16700",@"18800", nil];
#define TARI_ARRAY_18800                           [[NSArray alloc] initWithObjects:@"18800", nil];
#define TARI_ARRAY_25000                           [[NSArray alloc] initWithObjects:@"25000", nil];
#define TARI_ARRAY_25000_6300                      [[NSArray alloc] initWithObjects:@"12500",@"18800",@"25000", nil];
#define TARI_ARRAY_18800_6300                      [[NSArray alloc] initWithObjects:@"12500",@"18800", nil];
#define TARI_ARRAY_0                      [[NSArray alloc] initWithObjects:@"0", nil];

#define PIE_ARRAY_GENERAL                       [[NSArray alloc] initWithObjects:@"1500",@"2000", nil];
#define PIE_ARRAY_668                           [[NSArray alloc] initWithObjects:@"668", nil];
#define PIE_ARRAY_2000                          [[NSArray alloc] initWithObjects:@"2000", nil];
#define PIE_ARRAY_0                          [[NSArray alloc] initWithObjects:@"0", nil];

#define ZERO_STRING            @"0"
// RFID Antenna PIE statis values
#define ANTENNA_KEY_PIE                         @"PIE"
#define ANTENNA_KEY_DEFAULTS                    @"SelectedPIE"

#define NO_OF_SECTION_IN_ADVANCED_READER_OPTION   1
#define NO_OF_ROW_IN_ADVANCED_READER_OPTION       6
#define ANTENNA_ROW                               0
#define SINGULATION_ROW                           1
#define START_STOP_TRIGGER_ROW                    2
#define TAG_REPORTING_ROW                         3
#define SAVE_CONFIGURATION_ROW                    4
#define POWER_MANAGEMENT_ROW                      5
#define DEFAULT_INDEX                            -1

#define PROFILE_TITLE                            @"Profiles"
#define NO_OF_SECTION_IN_PROFILES                 1
#define NO_OF_ROW_IN_PROFILES                     7
#define FASTEST_READ_ROW                          0
#define CYCLE_COUNT_ROW                           1
#define DENSE_READERS_ROW                         2
#define OPTIMAL_BATTERY_ROW                       3
#define BALANCED_PERFORMANCE_ROW                  4
#define USER_DEFINED_ROW                          5
#define READER_DEFINED_ROW                        6

#define LEFT                        0.0
#define RIGHT                       0.0
#define TOP                         0.0
#define BOTTOM                      150.0

#define INDEX                       0


#define INVENTORY_IN_BATCH_MODE @"Inventory Started in Batch Mode"
#define INVENTORY_TAG_READING_INPROGRESS @"Inventory operation in-progress: operation not allowed"
#define OPERATION_FAILED @"Operation failed"
#define OPERATION_FAILED_MSG @"Operation failed: %@"
#define OPERATION_FAILED_TIMEOUT @"Operation failed: timeout"
#define OPERATION_FAILED_NO_ACTIVE_READER @"Operation failed: no active reader"

#define TIME_15_SECOND 1500
#define TIME_10_MILI_SECOND 10000

/// Barcode Data Table View Controller
#define BARCODE_DATA_VIEW_TITLE @"Barcode"
#define BARCODE_DATA_VIEW_NUMBER_OF_SECTION 1
#define BARCODE_DATA_VIEW_NUMBER_ROW_IN_SECTION_0 3
#define BARCODE_DATA_VIEW_NUMBER_ROW_IN_SECTION_1_EMPTY_DATA 1
#define BARCODE_DATA_VIEW_NUMBER_ROW_IN_SECTION_DEFAULT 0
#define BARCODE_DATA_VIEW_PULL_TRIGGER @"Pull Trigger"
#define BARCODE_DATA_VIEW_RELEASE_TRIGGER @"Release Trigger"
#define BARCODE_DATA_VIEW_SCAN @"Scan"
#define BARCODE_DATA_VIEW_UNKNOWN @"Unknown"
#define BARCODE_DATA_ACTION_CELL_ID @"BarcodeActionCell"
#define BARCODE_DATA_VIEW_DATA_CELL_ID @"BarcodeDataCell"
#define BARCODE_DATA_VIEW_NO_DATA_CELL_ID @"BarcodeNoDataCell"
#define BARCODE_DATA_VIEW_NO_BARCODE_RECEIVED @"No barcode received"
#define BARCODE_DATA_VIEW_CLEAR @"Clear"
#define BARCODE_DATA_VIEW_ACTION_TITLE @"Actions"
#define BARCODE_DATA_VIEW_BARCODE_LIST_WITH_COUNT_TITLE @"Barcode List: Count = %d"
#define BARCODE_DATA_VIEW_ACTION_SECTION_INDEX 0
#define BARCODE_DATA_VIEW_DATA_SECTION_INDEX 0
#define BARCODE_DATA_VIEW_ALERT_TITLE @"Clear Barcode Data?"
#define BARCODE_DATA_VIEW_ALERT_MESSAGE @"Are you sure that you want to clear all barcode data? This information cannot be restored after it is cleared."
#define BARCODE_DATA_VIEW_ALERT_CANCEL @"Cancel"
#define BARCODE_DATA_VIEW_ALERT_CONTINUE @"Continue"
#define BARCODE_DATA_VIEW_DATA_CANNOT_DISPLAY_AS_STRING @"Data cannot be displayed as string:"
#define BARCODE_DATA_VIEW_DECODE_DATA_FORMATER @"0x%02X "
#define BARCODE_DATA_VIEW_CLEAR_HEADER_HEIGHT 20.0f
#define BARCODE_DATA_VIEW_CLEAR_BUTTON_WIDTH 60.0f
#define BARCODE_DATA_VIEW_CLEAR_BUTTON_HEIGHT 30.0f
#define ZT_RFID_CANNOT_PERFORM_TRIGGER_PULL @"Cannot perform [Trigger Pull] action"
#define ZT_RFID_CANNOT_PERFORM_TRIGGER_RELEASE @"Cannot perform [Trigger Release] action"
#define ZT_RFID_CANNOT_PERFORM_BATCH_REQUEST @"Cannot perform batch request"

/// NXP Validation Strings
#define NXP_BRANDID_REQUIRED_STRING @"The brand-id field is required"
#define NXP_EPCLENGTH_REQUIRED_STRING @"EPC Length value should not be more than 255"
#define NXP_EPC_REQUIRED_STRING @"The EPC length field is required"

/// Barcode Full View
#define BARCODE_FULL_VIEW_TITLE @"Barcode Details"
#define BARCODE_FULL_VIEW_SCANNER_ID_FORMAT @"%d"
#define BARCODE_FULL_VIEW_BARCODE_TYPE_FORMAT @"%@"
/* invalid scanner id */
#define SBT_SCANNER_ID_INVALID           0x00

#define SCANNER_STORY_BOARD_NAME                        @"BarcodeDataView"
#define SCANNER_FIRMWARE_UPDATE_STORY_BOARD_NAME        @"FirmwareUpdate"
#define SCANNER_FACTORY_RESET_STORY_BOARD_NAME          @"FactoryStoryboard"
#define SCANNER_PRO_CLIP_STORY_BOARD_NAME               @"ProClipSettingStoryboard"
#define SCANNER_BATTERY_STATUS_STORY_BOARD_NAME         @"GetBatteryStatusStoryboard"


#define SCANNER_SYMBOLOGIES_STORY_BOARD_NAME            @"Symbologies"
#define SCANNER_LEDCONTROLL_STORY_BOARD_NAME            @"LedControll"
#define SCANNER_ASSET_DETAILS_STORY_BOARD_NAME          @"AssetDetails"
#define TRIGGER_MAPPING_STORY_BOARD_NAME          @"Trigger"
#define SCANNER_ASSET_INFORMATION_TITLE                 @"Device Information"
#define SCANNER_ASSET_INFORMATION_TABLE_VALUES          @"values"
#define SCANNER_ASSET_INFORMATION_TABLE_TITLES          @"titles"
#define SCANNER_ASSET_INFORMATION_TABLE_CELL            @"cell"
#define SCANNER_ASSET_INFORMATION_DOM                   @"Manufacture Date:"
#define SCANNER_ASSET_INFORMATION_INXML_ALL                @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d,%d,%d,%d</attrib_list></arg-xml></cmdArgs></inArgs>"
#define SCANNER_ASSET_INFORMATION_INXML_FIRMWARE_ONLY @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>"
#define SCANNER_ASSET_INFORMATION_ATTRIBUTE_START          @"<attrib_list><attribute>"
#define SCANNER_ASSET_INFORMATION_ATTRIBUTE_END             @"</attribute></attrib_list>"
#define SCANNER_ASSET_INFORMATION_ATTRIBUTE_TAG             @"</attribute><attribute>"
#define SCANNER_ASSET_INFORMATION_ID_START_TAG              @"<id>"
#define SCANNER_ASSET_INFORMATION_ID_END_TAG                @"</id>"
#define SCANNER_ASSET_INFORMATION_VALUE_START_TAG                   @"<value>"
#define SCANNER_ASSET_INFORMATION_VALUE_END_TAG                     @"</value>"
#define SCANNER_ASSET_INFORMATION_DEVICE_CONFIGURATION_TYPE_MFI                    @"MFi"
#define SCANNER_ASSET_INFORMATION_DEVICE_CONFIGURATION_TYPE_BTLE                   @"BT LE"
#define SCANNER_ASSET_INFORMATION_DEVICE_CONFIGURATION_TYPE_UNKNOWWN         @"Unknown"
#define SCANNER_ASSET_INFORMATION_TABLE_ROW_COUNT           8
#define SCANNER_ASSET_INFORMATION_TABLE_ROW_COUNT_PL500           7
#define SCANNER_ASSET_INFORMATION_SECTION_COUNT             1
#define SCANNER_ASSET_INFORMATION_TABLE_DOM_ROW           5
#define SCANNER_ASSET_INFORMATION_TABLE_ZERO_ROW           0
#define SCANNER_ASSET_INFORMATION_CANCEL_TEXT         @"Cancel"
#define STORY_BOARD_ID_SETTINGS                         @"ID_SCAN_SETTINGS_VIEW_CONTROLLER"
#define SCANNER_SETTINGS_SECTION_COUNT                  1
#define SCANNER_SETTINGS_ROWS_COUNT                     4
#define SCANNER_SETTINGS_ROW_HEIGHT                     46.0
#define SCANNER_SETTINGS_SYMBOLOGIES_ROW                  0
#define SCANNER_SETTINGS_BEEPER_ROW                       1
//#define SCANNER_SETTINGS_ENABLE_SCAN_ROW                  2
//#define SCANNER_SETTINGS_DESABLE_SCAN_ROW                 3
#define SCANNER_SETTINGS_AIM_ON_ROW                       2
#define SCANNER_SETTINGS_AIM_OFF_ROW                      3
//#define SCANNER_SETTINGS_VIB_FEEDBACK_ROW                 6
//#define SCANNER_SETTINGS_UPDATE_FIRMWARE_ROW              7
//#define SCANNER_SETTINGS_VIRTUAL_TETHER_ROW               8
#define SCANNER_SETTINGS_SCAN_XML                       @"<inArgs><scannerID>%d</scannerID></inArgs>"
#define SCANNER_PULL_RELEASE_TRIGGER_SCAN_XML                   @"<inArgs><scannerID>%d</scannerID></inArgs>"
#define SCANNER_SETTINGS_BARCODE_CELL_HEIGHT              60
#define SCANNER_SETTINGS_DEFAULT_CELL_HEIGHT              44
#define SCANNER_SETTINGS_NO_SCAN_CELL_HEIGHT              100

///Led control
#define ZT_SCANNER_CANNOT_PERFORM_LED_ACTION        @"Cannot perform LED action"
#define SCANNER_LEDCONTROLL_PAGE_TITLE              @"LED Actions"
#define SCANNER_LEDCONTROLL_GREEN_LED_ON            @"Green LED ON"
#define SCANNER_LEDCONTROLL_RED_LED_ON              @"RED LED ON"
#define SCANNER_LEDCONTROLL_YELLOW_LED_ON            @"YELLOW LED ON"
#define SCANNER_LEDCONTROLL_GREEN_LED_OFF            @"Green LED OFF"
#define SCANNER_LEDCONTROLL_RED_LED_OFF              @"RED LED OFF"
#define SCANNER_LEDCONTROLL_YELLOW_LED_OFF            @"YELLOW LED OFF"
#define SCANNER_LEDCONTROLL_CEL                     @"LedActionCell"
#define SCANNER_LEDCONTROLL_INXML                   @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-int>%d</arg-int></cmdArgs></inArgs>"
#define SCANNER_LEDCONTROLL_ROWS_IN_SECTION            2

/// Firmware Update
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_ONE        @"1. Delete the incorrect plug-in from the application's download folder."
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_TWO        @"2. Copy the correct plug-in to the application's download folder."
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_STRING_FORMAT @"%@\n\n%@"
#define ZT_FW_FILE_DIRECTIORY_NAME                 @"Download"
#define ZT_FW_FILE_EXTENTION                       @"DAT"
#define ZT_PLUGIN_FILE_EXTENTION                   @"SCNPLG"
#define ZT_PLUGIN_DEFAULT_DOCUMENT                 @"Documents"
#define ZT_RELEASE_NOTES_FILE_EXTENTION            @"txt"
#define ZT_METADATA_FILE                           @"Metadata.xml"
#define ZT_MODEL_LIST_TAG                          @"models"
#define ZT_FIRMWARE_NAME_TAG                       @"combined-firmware"
#define ZT_MODEL_TAG                               @"model"
#define ZT_REVISION_TAG                            @"revision"
#define ZT_FAMILY_TAG                              @"family"
#define ZT_NAME_TAG                                @"name"
#define ZT_PICTURE_FILE_NAME                       @"picture"
#define ZT_RELEASED_DATE_TAG                       @"release-date"
#define ZT_UPDATE_FW_BTN_TITLE                     @"UPDATE FIRMWARE"
#define ZT_UPDATE_FW_BTN_TITLE_UPDATED             @"✓ FIRMWARE UPDATED"
#define ZT_SCANNER_CANNOT_RETRIEVE_ASSET_INFORMATION @"Cannot retrieve asset information from the device"
#define ZT_SCANNER_CANNOT_REBOOT_THE_DEVICE @"Cannot reboot the device"
#define ZT_SCANNER_REBOOT_THE_DEVICE @"Sucessfully reboot the device"

#define ZT_SCANNER_ERROR_MESSAGE @"Error"
#define ZT_FW_NAME_STRING_FORMAT @"%@ %@"
#define ZT_FW_NAME_FROM_STRING @"From:"
#define ZT_FW_UPDATE_EMPTY_STRING @""
#define ZT_FW_UPDATE_DATE_FORMAT_dd_MM_yyyy @"dd/MM/yyyy"
#define ZT_FW_UPDATE_DATE_FORMAT_MM_dd_yyyy @"MM/dd/yyyy"
#define ZT_FW_UPDATE_DATE_FORMAT_DOT_yyyy_dd_MM @"yyyy.dd.MM"
#define ZT_FW_UPDATE_CURRENT_RELEASE_FORMAT @"Current: Release %@ - %@ (%@)"
#define ZT_FW_UPDATE_TO_RELEASE_FORMAT @"To: Release %@ - %@ (%@)"
#define ZT_FW_UPDATE_TO_RELEASE_FORMAT_FOR_DAT @"To: %@"
#define ZT_FW_UPDATE_SCANNER_INFO_GET_XML @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>"
#define ZT_FW_UPDATE_SCANNER_INFO_GET_FIRMWARE_CODE 20012
#define ZT_FW_UPDATE_SCANNER_INFO_GET_MODEL_NUMBER 533
#define ZT_FW_UPDATE_ATTRIBUTE_START_XML @"<attrib_list><attribute>"
#define ZT_FW_UPDATE_ATTRIBUTE_END_XML @"</attribute></attrib_list>"
#define ZT_FW_UPDATE_ATTRIBUTE_START_END_XML @"</attribute><attribute>"
#define ZT_FW_UPDATE_ID_START_XML @"<id>"
#define ZT_FW_UPDATE_ID_END_XML @"</id>"
#define ZT_FW_UPDATE_VALUE_START_XML  @"<value>"
#define ZT_FW_UPDATE_VALUE_END_XML @"</value>"
#define ZT_FW_UPDATE_SPACE_STRING @" "
#define ZT_FW_UPDATE_SPINNER_SIZE 25.0
#define ZT_FW_UPDATE_SPINNER_SIZE_DIVIDE 2.0
#define ZT_FW_UPDATE_CONTENT_READER_INIT_ELAPSED_TIME 0
#define ZT_FW_UPDATE_CONTENT_READER_ELAPSED_TIME 20
#define ZT_FW_UPDATE_CONTENT_READER_THREAD_SLEEP 0.1
#define ZT_FW_UPDATE_UPDATE_BUTTON_COLOR 0x007CB0
#define ZT_FW_UPDATE_NAME_STRING_INDEX 3
#define ZT_FW_UPDATE_PLUGINS_ARRAY_COUNT_ZERO 0
#define ZT_FW_UPDATE_PLUGINS_ARRAY_FILE_INDEX 0
#define ZT_FW_UPDATE_NON_DAT_FILE_COUNT 0
#define FIRMWARE_UPDATE_STOPPED @"Firmware Update Stopped."
#define FIRMWARE_UPDATE_FAILED @"Firmware update failed."
#define ZT_SCANNER_CANNOT_PERFORM_NEW_FIRMWARE_ACTION @"Cannot perform [Start new firmware] action"
#define ZT_FW_UPDATE_START_XML @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-string>%@</arg-string></cmdArgs></inArgs>"
#define START_PROGRESS_RESET_VALUE      0.0
#define FIRMWARE_UPDATE_RESET_AMOUNT    0.0f
#define ZT_FW_ATTRIBUTE_SCANNER_XML_FORMAT @"<inArgs><scannerID>%d</scannerID></inArgs>"
#define ZT_FW_UPDATE_PROGRESS_FORMAT_WITH_VALUE @"%d%%"
#define ZT_FW_UPDATE_PROGRESS_100_PERCENT 100
#define ZT_FW_UPDATE_PROGRESS_10_PERCENT 10
#define ZT_FW_UPDATE_PROGRESS_ZERO 0
#define ZT_FW_UPDATE_TEMPORARY_FRAME_X_Y 0
#define ZT_FW_UPDATE_TEMPORARY_COLOR 0xF2F2F2
#define ZT_FW_UPDATE_TEMPORARY_ALPHA 0.3
#define ZT_FW_UPDATE_TEMPORARY_CONSTANT_MULTIPLIER 1.0
#define ZT_FW_UPDATE_TEMPORARY_CONSTANT_ZERO 0
#define ZT_FW_UPDATE_FAST_LED_XML_FORMAT @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-int>%d</arg-int></cmdArgs></inArgs>"
#define ZT_FW_UPDATE_REBOOTING @"Rebootig Scanner"
#define ZT_FW_UPDATE_PROGRESS_UI_100_PERCENT 100.0
#define FIRMWARE_UPDATE_CANCEL_CONFIRMATION @"Do you want to cancel this firmware update?"
#define YES_BUTTON @"Yes"
#define NO_BUTTON @"No"
#define FIRMWARE_UPDATE_STOPPED @"Firmware Update Stopped."
#define ZT_FW_PROGRESS_FORMAT_WITH_VALUE_FLOAT @"%f%%"
#define ZT_FIRMWARE_UPDATING @"Updating Firmware."
#define ZT_FIRMWARE_CANCEL_THREAD_SLEEP 5.0

///Plugins file content reader
#define ZT_PLUGINS_FILE_CONTENT_READER_ZERO_INDEX 0
#define ZT_PLUGINS_FILE_CONTENT_READER_LINE_BREAK @"\n"
#define ZT_PLUGINS_FILE_CONTENT_READER_EMPTY_STRING @""
#define ZT_PLUGINS_FILE_CONTENT_READER_SPACE_STRING @" "
#define ZT_PLUGINS_FILE_CONTENT_READER_FAMILY_FORMAT @"%@,%@"
#define ZT_PLUGINS_FILE_CONTENT_READER_KEY_NAME @"name"
#define ZT_PLUGINS_FILE_CONTENT_READER_COMPONENT @"component"

typedef enum {
    ZT_INFO_UPDATE_FROM_DAT                   = 0x00,
    ZT_INFO_UPDATE_FROM_PLUGIN                = 0x01,
} ZT_INFO_UPDATE_FIRMWARE;

///iPad constraints
#define FW_PAGE_DEVICE_IMG_HEIGHT_IPAD 150.0
#define FW_PAGE_BUTTON_HEIGHT_IPAD 50.0
#define FW_PAGE_DETAIL_VIEW_HEIGHT_IPAD 250.0
#define VIRTUAL_TETHER_PAGE_BUTTON_HEIGHT_IPAD 50.0

/// Multitag implementation
#define ZT_UI_LOCATE_MULTITAG_INDICATOR_CORNER_RADIUS               8
#define ZT_TAG_LOCATE_NUM_OF_SECTION                                1
#define ZT_TAG_LOCATE_NUM_OF_ROW                                    5
#define LOCATE_SINGLE_TAG                                           @"SINGLE TAG"
#define LOCATE_MULTI_TAG                                            @"MULTI TAG"
#define ASCII_MODE_FILE_EXTENSION                                   @"file://"
#define ASCII_MODE_SHARED_DOCUMENTS                                 @"shareddocuments://"
#define ZT_TAG_LOCATE_BUTTON_WIDTH_ACTIVE                           60
#define ZT_TAG_LOCATE_BUTTON_WIDTH_INACTIVE                         0

/// Firmware update help screen
#define ZT_FW_HELP_ICON_IMAGE @"help_icon"
#define FW_PAGE_HELP_PAGE_TITLE                    @"Firmware Update Process Help"
#define FW_PAGE_HELP_CONTENT_ONE                   @"1. Copy the correct DAT file to 123RFID Mobile/Download"
#define FW_PAGE_HELP_CONTECT_TWO                        @"2. Start the firmware update by clicking the UPDATE FIRMWARE button."
#define UPDATE_FIRMWARE_OPEN_URL_SUCCESS @"Success"
#define FW_PAGE_HELP_SCREEN_CONTENT_STRING_FORMAT @"%@\n\n%@\n\n%@"
#define ZT_MULTI_TAGDATA_DOCUMENT_TYPE_DATA              @"public.data"
#define ZT_MULTI_TAGDATA_DOCUMENT_TYPE_TEXT              @"public.text"
#define ZT_TAGLIST_DEFAULTS_KEY                          @"tagListEnabled"
#define ZT_TAGLIST_ARRAY_DEFAULTS_KEY                    @"tagListArray"
#define ZT_TAGLIST_DATA_NEXTLINE_KEY                     @"\n"
#define ZT_TAGLIST_FILE_CONTENT_EMPTY_STRING @""
#define ZT_TAGLIST_ALERT_MESSAGE_STRING                  @"All tags matched"
#define ZT_TAGLIST_EMPTY_STRING                          @""

#define TAG_SELECTION_COLOR [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1.0];
#define TAG_ID_CANNOT_BE_ADDED @"This tag id cannot be added.Please add already selected tag id from inventory page"
#define ZT_TAG_DATA_EMPTY_SPACE                            @" "

// Symbologies
#define ZT_SYMBOLOGIES_TITLE @"Symbologies"
#define ZT_SCANNER_SETTINGS_TITLE @"Scanner Settings"
#define ZT_SYMBOLOGIES_PERMANENT @"Permanent"
#define ZT_SYMBOLOGIES_OBJECT_STRING_FORMAT @"%@"
#define ZT_SYMBOLOGIES_CELL_INDENTIFIER @"SymbologyCell"
#define ZT_SYMBOLOGIES_CODE_UPC_A @"UPC-A"
#define ZT_SYMBOLOGIES_CODE_UPC_E @"UPC-E"
#define ZT_SYMBOLOGIES_CODE_UPC_E1 @"UPC-E1"
#define ZT_SYMBOLOGIES_CODE_EAN_8_OR_JAN8 @"EAN-8/JAN8"
#define ZT_SYMBOLOGIES_CODE_EAN_13_OR_JAN13 @"EAN-13/JAN13"
#define ZT_SYMBOLOGIES_CODE_Bookland_EAN @"Bookland EAN"
#define ZT_SYMBOLOGIES_CODE_Code_128 @"Code 128"
#define ZT_SYMBOLOGIES_CODE_GS1_128 @"GS1-128"
#define ZT_SYMBOLOGIES_CODE_Code_39 @"Code 39"
#define ZT_SYMBOLOGIES_CODE_Code_93 @"Code 93"
#define ZT_SYMBOLOGIES_CODE_Code_11 @"Code 11"
#define ZT_SYMBOLOGIES_CODE_Interleaved_2_of_5 @"Interleaved 2 of 5"
#define ZT_SYMBOLOGIES_CODE_Discrete_2_of_5 @"Discrete 2 of 5"
#define ZT_SYMBOLOGIES_CODE_Chinese_2_of_5 @"Chinese 2 of 5"
#define ZT_SYMBOLOGIES_CODE_Codabar @"Codabar"
#define ZT_SYMBOLOGIES_CODE_MSI @"MSI"
#define ZT_SYMBOLOGIES_CODE_Data_Matrix @"Data Matrix"
#define ZT_SYMBOLOGIES_CODE_PDF @"PDF"
#define ZT_SYMBOLOGIES_CODE_ISBT_128 @"ISBT 128"
#define ZT_SYMBOLOGIES_CODE_UCCCouponExtendedCode @"UCCCouponExtendedCode"
#define ZT_SYMBOLOGIES_CODE_US_Postnet @"US Postnet"
#define ZT_SYMBOLOGIES_CODE_US_Planet @"US Planet"
#define ZT_SYMBOLOGIES_CODE_UK_Post @"UKPost"
#define ZT_SYMBOLOGIES_CODE_USPostal_Check_Digit @"USPostal Check Digit"
#define ZT_SYMBOLOGIES_CODE_UKPostal_Check_Digit @"UKPostal Check Digit"
#define ZT_SYMBOLOGIES_CODE_JapanPost @"JapanPost"
#define ZT_SYMBOLOGIES_CODE_AusPost @"AusPost"
#define ZT_SYMBOLOGIES_CODE_GS1DataBar14 @"GS1DataBar14"
#define ZT_SYMBOLOGIES_CODE_GS1DataBarLimited @"GS1DataBarLimited"
#define ZT_SYMBOLOGIES_CODE_GS1DataBarExpanded @"GS1DataBarExpanded"
#define ZT_SYMBOLOGIES_CODE_MicroPDF @"MicroPDF"
#define ZT_SYMBOLOGIES_CODE_MaxiCode @"MaxiCode"
#define ZT_SYMBOLOGIES_CODE_ISSN_EAN @"ISSN EAN"
#define ZT_SYMBOLOGIES_CODE_Matrix_2_of_5 @"Matrix 2 of 5"
#define ZT_SYMBOLOGIES_CODE_Korean_3_of_5 @"Korean 3 of 5"
#define ZT_SYMBOLOGIES_CODE_QR_Code @"QR Code"
#define ZT_SYMBOLOGIES_CODE_Micro_QR_Code @"Micro QR Code"
#define ZT_SYMBOLOGIES_CODE_Aztec @"Aztec"
#define ZT_SYMBOLOGIES_CODE_HanXin @"HanXin"
#define ZT_SYMBOLOGIES_CODE_Composite_CC_C @"Composite CC-C"
#define ZT_SYMBOLOGIES_CODE_Composite_CC_A_OR_B @"Composite CC-A/B"
#define ZT_SYMBOLOGIES_CODE_Composite_TLC_39 @"Composite TLC-39"
#define ZT_SYMBOLOGIES_CODE_Netherlands_KIX @"Netherlands KIX"
#define ZT_SYMBOLOGIES_CODE_UPU_FICS @"UPU FICS"
#define ZT_SYMBOLOGIES_CODE_USPS_4CB_ONE_Code @"USPS 4CB/ONE Code"
#define ZT_SYMBOLOGIES_CODE_Code_32 @"Code 32"
#define ZT_SYMBOLOGIES_CODE_ISBN @"ISBN"
#define ZT_SYMBOLOGIES_CODE_Trioptic_Code_39 @"Trioptic Code 39"
#define ZT_SYMBOLOGIES_CANCEL_BAR_TITLE @"Cancel"
#define ZT_SYMBOLOGIES_RETRIEVING @"Retrieving Symbologies..."
#define ZT_SYMBOLOGIES_CANCEL_MESSAGE_ALERT @"Are you sure that you want to go back?"
#define ZT_SYMBOLOGIES_CANCEL_ALERT @"Cancel"
#define ZT_SYMBOLOGIES_CONTINUE_ALERT @"Continue"
#define ZT_SYMBOLOGIES_CONTINUE_ALERT @"Continue"
#define ZT_SYMBOLOGIES_SCANNER_XML @"<inArgs><scannerID>%d</scannerID></inArgs>"
#define ZT_SYMBOLOGIES_CANNOT_SUPPORT @"Cannot retrieve supported symbologies"
#define ZT_SYMBOLOGIES_ATTRIBUTE_NAME_LIST_START @"<attrib_list><attribute name=\"\">"
#define ZT_SYMBOLOGIES_ATTRIBUTE_LIST @"</attribute></attrib_list>"
#define ZT_SYMBOLOGIES_ATTRIBUTE_NAME_LIST_END @"</attribute><attribute name=\"\">"
#define ZT_SYMBOLOGIES_ATTRIBUTE_SCANNER_ID @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>"
#define ZT_SYMBOLOGIES_SCANNER_ID_FORMAT @"%d,"
#define ZT_SYMBOLOGIES_ATTRIBUTE_XML_ARG @"</attrib_list></arg-xml></cmdArgs></inArgs>"
#define ZT_SYMBOLOGIES_CANNOT_RETRIEVE_SUPPORTED @"Cannot retrieve supported symbologies. Please try again"
#define ZT_SYMBOLOGIES_ATTRIB_LIST_START_XML @"<attrib_list><attribute>"
#define ZT_SYMBOLOGIES_ATTRIB_LIST_END_XML @"</attribute></attrib_list>"
#define ZT_SYMBOLOGIES_ATTRIBUTE_START_XML @"</attribute><attribute>"
#define ZT_SYMBOLOGIES_ID_START @"<id>"
#define ZT_SYMBOLOGIES_ID_END @"</id>"
#define ZT_SYMBOLOGIES_VALUE_START @"<value>"
#define ZT_SYMBOLOGIES_VALUE_END @"</value>"
#define ZT_SYMBOLOGIES_VALUE_FALSE @"false"
#define ZT_SYMBOLOGIES_VALUE_TRUE @"true"
#define ZT_SYMBOLOGIES_FAILD_TO_CONFIGURE_MESSAGE @"Symbology configuration failed"
#define ZT_SYMBOLOGIES_PATTERN_XML @"<inArgs><scannerID>(\\d+)</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>(\\d+)</id><datatype>F</datatype><value>(.+)/value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>"
#define ZT_SYMBOLOGIES_VALUE_CAPS_TRUE @"True"
#define ZT_SYMBOLOGIES_VALUE_CAPS_FALSE @"False"
#define ZT_SYMBOLOGIES_INPUT_XML_FORMAT @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>%d</id><datatype>F</datatype><value>%@</value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>"
#define ZT_SYMBOLOGIES_RETRIEVED_ERROR_MESSAGE @"Supported symbologies have not been retrieved. Action will not be performed"
#define ZT_SYMBOLOGIES_SLEEP_TIME_INTERVAL 2.0
#define ZT_SYMBOLOGIES_VALUE_ONE 1
#define ZT_SYMBOLOGIES_ZERO 0
#define ZT_SYMBOLOGIES_NUMBER_OF_RANGE_FOUR 4
#define ZT_SYMBOLOGIES_2_INDEX 2
#define ZT_SYMBOLOGIES_3_INDEX 3
#define ZT_SYMBOLOGIES_SECTION_COUNT 1
#define ZT_SYMBOLOGIES_SECTION_RECT_ZERO 0
#define ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_X 0
#define ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_Y 5
#define ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_WIDTH 200
#define ZT_SYMBOLOGIES_SECTION_CHECK_BOX_RECT_HEIGHT 44
#define ZT_SYMBOLOGIES_SECTION_HEADER_HEIGHT 45
#define ZT_SYMBOLOGIES_CODE_DOTCODE @"DOTCODE"

//Aim on or off
#define ZT_AIM_CANNOT_PERFORM_ON @"Cannot perform [Aim On] action"
#define ZT_AIM_CANNOT_PERFORM_OFF @"Cannot perform [Aim Off] action"

// Export Data
#define ZT_EXPORTDATA_FILENAME                           @"TagList"
#define ZT_EXPORTDATA_FILENAME_CONVENTION                @".csv"
#define ZT_EXPORTDATA_INVENTORY_SUMMARY @"INVENTORY SUMMARY"
#define ZT_EXPORTDATA_UNIQUE_COUNT @"UNIQUE COUNT:"
#define ZT_EXPORTDATA__TOTAL_UNIQUE_COUNT_FORMAT @"%@,%d"
#define ZT_EXPORTDATA_TOTAL_COUNT @"TOTAL COUNT:"
#define ZT_EXPORTDATA_READ_TIME @"READ TIME:"
#define ZT_EXPORTDATA_FULL_FILE_FORMAT @"%@\n%@\n%@\n%@\n \n%@\n%@"
#define ZT_EXPORTDATA_ASCII_FORMAT @"%@"
#define ZT_EXPORTDATA_TAG_ROWS @"%@,%d,%d"
#define ZT_EXPORTDATA_TAG_ROW_LINE_BREAK @"\r\n"
#define ZT_EXPORTDATA_FILE_NAME_FORMAT @"%@%d%@"
#define ZT_EXPORTDATA_TAGS_HEADING @"%@,%@,%@"
#define ZT_EXPORTDATA_TAG_ID @"TAG ID"
#define ZT_EXPORTDATA_COUNT @"COUNT"
#define ZT_EXPORTDATA_RSSI @"RSSI"
#define ZT_EXPORTDATA_TIME_FORMAT @"%02d:%02d"
#define ZT_EXPORTDATA_CSV_TIME_FORMAT @"%@,%@"
#define ZT_EXPORTDATA_TIME_60 60
#define ZT_EXPORTDATA_THREAD_SLEEP 2.5
#define ZT_EXPORTDATA_FILE_INDEX 0
#define ZT_EXPORTDATA_MIN_CHECK_ZERO 0
#define ZT_EXPORTDATA_INIT_VALUE 1
#define ZT_EXPORTDATA_SET_ZERO 0
#define ZT_EXPORTDATA_SUCCESS_MESSAGE                    @"Inventory data has been exported successfully"
#define ZT_EXPORTDATA_FAILURE_MESSAGE                    @"Failed to export inventory data"
#define ZT_EXPORTDATA_CANCELLED_MESSAGE                    @"Inventory data export has been cancelled"
#define ZT_EXPORTDATA_LOADING   @"Loading..."

//asset infomation
#define ZT_RFID_SURE_WANT_GO_BACK @"Are you sure that you want to go back?"
#define ACTIVE_SCANNER_TITLE @"Active Scanner"
#define ACTIVE_SCANNER_BACK_BUTTON_TITLE @"Back"
#define ACTIVE_SCANNER_DISCONNECT_ALERT_TITLE @"Disconnect?"
#define ACTIVE_SCANNER_DISCONNECT_ALERT_MESSAGE @"This will disconnect the application from the scanner, however the device will still be paired to the system."
#define ACTIVE_SCANNER_DISCONNECT_ALERT_CANCEL @"Cancel"
#define ACTIVE_SCANNER_DISCONNECT_ALERT_CONTINUE @"Continue"
#define ACTIVE_SCANNER_BARCODE_ALERT_TITLE @"Clear Barcode Data?"
#define ACTIVE_SCANNER_BARCODE_ALERT_MESSAGE @"Are you sure that you want to clear all barcode data? This information cannot be restored after it is cleared."
#define ACTIVE_SCANNER_BARCODE_ALERT_CANCEL @"Cancel"
#define ACTIVE_SCANNER_BARCODE_ALERT_CONTINUE @"Continue"
#define ZT_SCANNER_CANNOT_RETRIEVE_ASSET_MESSAGE @"Cannot retrieve asset information from the device"
#define ZT_SCANNER_ERROR_MESSAGE @"Error"

//Beeper
#define BEEPER_SETTINGS_TITLE @"Beeper Settings"
#define BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_MESSAGE @"Cannot retrieve beeper settings"
#define BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_OK_TITLE @"OK"
#define RMD_ATTR_BEEPER_VOLUME                          140
#define RMD_ATTR_BEEPER_FREQUENCY                       145
#define RMD_ATTR_VALUE_BEEPER_VOLUME_LOW                2
#define RMD_ATTR_VALUE_BEEPER_VOLUME_MEDIUM             1
#define RMD_ATTR_VALUE_BEEPER_VOLUME_HIGH               0
#define RMD_ATTR_VALUE_BEEPER_FREQ_LOW                  2
#define RMD_ATTR_VALUE_BEEPER_FREQ_MEDIUM               1
#define RMD_ATTR_VALUE_BEEPER_FREQ_HIGH                 0
#define ZT_SCANNER_CANNOT_RETRIEVE_BEEPER_SETTINGS @"Cannot retrieve beeper settings"
#define ZT_SCANNER_BEEPER_SETTINGS_XML @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d,%d</attrib_list></arg-xml></cmdArgs></inArgs>"
#define ZT_SCANNER_RETRIEVE_ATTRIBUTE @"<attrib_list><attribute>"
#define ZT_SCANNER_RETRIEVE_CLOSE_ATTRIBUTE @"</attribute></attrib_list>"
#define ZT_SCANNER_RETRIEVE_CLOSE_OPEN_ATTRIBUTE @"</attribute><attribute>"
#define ZT_SCANNER_ID_XML @"<id>"
#define ZT_SCANNER_ID_CLOSE_XML @"</id>"
#define ZT_SCANNER_VALUE_XML @"<value>"
#define ZT_SCANNER_VALUE_CLOSE_XML @"</value>"
#define ZT_BEEPER_ZERO 0
#define ZT_BEEPER_SECTION_ZERO 0
#define ZT_BEEPER_SECTION_ONE 1
#define ZT_BEEPER_SECTION_TWO 2
#define ZT_BEEPER_LOOP_ZERO 0
#define ZT_BEEPER_LOOP_TOTAL_THREE 3
#define ZT_BEEPER_LOOP_TOTAL_TWO 2
#define ZT_BEEPER_SLEEP_THREAD 2.0
#define ZT_SCANNER_CANNOT_APPLY_BEEPER_CONFIG @"Cannot apply beeper configuration"
#define ZT_BEEPER_NUMBER_OF_SECTION 2
#define ZT_BEEPER_SECTION_CASE_ZERO 0
#define ZT_BEEPER_SECTION_CASE_ONE 1
#define ZT_BEEPER_ROW_TOTAL_THREE 3
#define ZT_BEEPER_VALUE_INIT 1
#define ZT_BEEPER_SELECT_LOOP_THREE 3
#define ZT_BEEPER_DID_SELECT_ZERO 0
#define ZT_BEEPER_VOLUME_SECTION 0
#define ZT_BEEPER_VOLUME_LOW 0
#define ZT_BEEPER_VOLUME_MEDIUM 1
#define ZT_BEEPER_VOLUME_HIGH 2
#define ZT_BEEPER_FREQUENCY_SECTION 1
#define ZT_BEEPER_FREQUENCY_LOW 0
#define ZT_BEEPER_FREQUENCY_MEDIUM 1
#define ZT_BEEPER_FREQUENCY_HIGH 2
#define ZT_BEEPER_SETTING_SET_XML @"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>%d</id><datatype>B</datatype><value>%d</value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>"
#define ZT_SCANNER_BEEPER_SETTINGS_NOT_RETRIEVED @"Beeper settings have not been retrieved. Action will not be performed"

// Validation messages
#define ZT_INVENTORY_ERROR_MESSAGE @"Operation Failed: Inventory In Progress-Command Not Allowed"
#define ZT_SINGLETAG_ERROR_MESSAGE @"Operation Failed: Operation In Progress-Command Not Allowed"
#define ZT_MULTITAG_ERROR_MESSAGE @"Operation Failed: MultiTag Locate In Progress-Command Not Allowed"
#define ZT_GENERAL_ERROR_MESSAGE @"Operation Failed: Operation In Progress-Command Not Allowed"
#define ZT_ALERTVIEW_WAITING_TIME 3

// Application changes
#define APPLICATION_DEFAULTS_KEY                @"applicationUpdates"
#define SAVE_APPLICATION_SETTINGS               @"Saving application settings"
#define PROFILE_DEFAULTS_KEY                    @"isProfileChanged"
#define FACTORY_RESET_MODE_KEY                  @"fromFactoryReset"
#define DEVICE_INFORMATION_TYPE_FORMAT          @"%@"
#define DEVICE_SCANNER_MODEL_INDEX_0            0
#define DEVICE_SCANNER_MODEL_INDEX_1            1
#define DEVICE_SCANNER_MODEL_INDEX_2            2
#define DEVICE_SCANNER_MODEL_INDEX_3            3
#define DEVICE_SCANNER_MODEL_INDEX_4            4
#define DEVICE_SCANNER_MODEL_INDEX_5            5
#define DEVICE_SCANNER_MODEL_INDEX_6            6
#define DEVICE_SCANNER_MODEL_INDEX_7            7

//Trigger Mapping
#define TRIGGER_MAPPING_TITLE @"Trigger Mapping"
#define ZT_TRIGGER_MAPPING_ZERO                 0
#define ZT_TRIGGER_MAPPING_SELECTED             @"Trigger Selected :"
#define ZT_TRIGGER_MAPPING_CONFIG_UPPER_LOWER   @"Upper(%@) & Lower(%@)"
#define ZT_TRIGGER_MAPPING_CONFIG_UPPER_LOWER_NOT_ALLOWED  @"Upper(%@)Lower(%@) Option Not Allowed"
#define ZT_TRIGGER_MAPPING_INT_FORMAT           @"%u"
#define ZT_TRIGGER_MAPPING_STRING_FORMAT        @"%@ %@"
#define ZT_TRIGGER_MAPPING_DEFAULTS_KEY          @"triggerConfiguration"
#define ZT_TRIGGER_MAPPING_NOT_SUPPORT_MESSAGE   @"Trigger Mapping feature is not supported for "
#define ZT_PRO_CLIP_NOT_SUPPORT_MESSAGE   @"Pro Clip feature is not supported for "
#define ZR_DEVICE_RESET_NOT_SUPPORT_MESSAGE @"Device reset is not supported for "
#define ZT_BATTERY_PP_NOT_SUPPORT_MESSAGE   @"Get Battery Status feature is not supported for "
#define ZT_TRIGGER_MAPPING_ALERT_DURATION        2
#define ZT_SCANNER_SETTING_ALERT_DURATION        2
#define ZT_IMPINJ_NOT_SUPPORT_MESSAGE @"Impinj tag config feature is not supported for "

#define ZT_READER_NAME_CONTAINS_STANDARD                        @"RFD40S"
#define ZT_TRIGGER_MAPPING_CHECK_STRING_NONE                    @"NONE"
#define ZT_TRIGGER_MAPPING_SCANNER_NAME_CONTAINS                @"RFD8500"
#define ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_E8               @"E8"
#define ZT_TRIGGER_MAPPING_SCANNER_MODEL_CONTAINS_WR               @"WR"
#define ZT_TRIGGER_MAPPING_RFID @"RFID"
#define ZT_TRIGGER_MAPPING_DEVICE_SCAN @"Device Scan"
#define ZT_TRIGGER_MAPPING_TERMINAL @"Terminal Scan"
#define ZT_TRIGGER_MAPPING_SCAN_NOTIFICATION @"Scan Notification"
#define ZT_TRIGGER_MAPPING_NO_ACTION @"No Action"
#define ZT_TRIGGER_MAPPING_BUTTON_TITLE @"Apply"
#define ZT_TRIGGER_MAPPING_EMPTY_STRING @""
#define ZT_TRIGGER_MAPPING_LOADING @"Loading...."
#define ZT_TRIGGER_BEEPER_LOADING @"Loading...."
#define ZT_TRIGGER_MAPPING_DURATION 1.0
#define RFID_Index  0
#define SledScan_Index 1
#define TerminalScan_Index 2
#define ScanNotification_Index 3
#define NoAction_Index 4
#define ZT_TRIGGER_PICKER_COMPONENTS 1
#define ZT_TRIGGER_PICKER_COMPONENT_INDEX 0
#define ZT_TRIGGER_PICKER_PRESENTED_TEXT @"The selected trigger configuration is already presented"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


//Share File
#define ZT_SHARE_FILE_FORMAT @"%@"

// Cycle count
#define ZT_CYCLECOUNT_THREAD_SLEEP              1.0
#define ZT_UNIQUETAGS_DEFAULTS_KEY                       @"UniquetagsCount"
#define ZT_TOTALREADS_DEFAULTS_KEY                       @"TotalReadsCount"
#define ZT_CYCLECOUNT_DEFAULT_VALUE_ZERO        0
#define ZT_CYCLECOUNT_INT_FORMAT                @"%d"
#define ZT_CYCLECOUNT_LONG_FORMAT               @"%lu"
#define ZT_CYCLECOUNT_FONT_SIZE                 19.0


#define EMPTY_TAG  @"Please select the TagID"
#define INVALID_TAG  @"invalid TagID - Parameter length is invalid"

// Host Beeper
#define ZT_HOST_BEEPER_SYSTEM_SOUND_ID              1054

// Taglist Filter
#define ZT_TAGLIST_FILTER_ZERO                  0
#define ZT_TAGLIST_FILTER_ONE                   1
#define ZT_TAGLIST_FILTER_TWO                   2
#define ZT_TAGLIST_FILTER_THREE                 3

#define ZT_TAGLIST_FILTER_ALL                   @"All"
#define ZT_TAGLIST_FILTER_MATCHING              @"Matching"
#define ZT_TAGLIST_FILTER_MISSING               @"Missing"
#define ZT_TAGLIST_FILTER_UNKNOWN               @"Unknown"

#define ZT_TAGLIST_UNIQUE_TAGS                  @"UNIQUE TAGS"
#define ZT_TAGLIST_TOTAL_TAGS                   @"TOTAL TAGS"
#define ZT_TAGLIST_MISSING_TAGS                 @"MISSING TAGS"
#define ZT_TAGLIST_MATCHING_TAGS                @"MATCHING TAGS"
#define ZT_TAGLIST_BATBUTTON_OPTIONS            @"Options"
#define ZT_TAGLIST_STRING_FORMAT                @"%@"
#define ZT_TAGLIST_BATBUTTON_HIDE               @"Hide"

#define ZT_TAGLIST_FILTER_CASE_ZERO                  0
#define ZT_TAGLIST_FILTER_CASE_ONE                   1
#define ZT_TAGLIST_FILTER_CASE_TWO                   2
#define ZT_TAGLIST_FILTER_CASE_THREE                 3
#define ZT_TAGLIST_ARRAY_COUNT_ZERO                  0


// MultiTag Locationing
#define ZT_MULTITAG_LOCATE_ADDTAG_SUCCESS_MESSAGE @"Add Tag Item successfully"
#define ZT_MULTITAG_LOCATE_ADDTAG_ERROR_MESSAGE @"Add Tag Item failed"
#define ZT_MULTITAG_LOCATE_REMOVETAG_SUCCESS_MESSAGE @"Delete Tag Item successfully"
#define ZT_MULTITAG_LOCATE_REMOVETAG_ERROR_MESSAGE @"Delete Tag Item failed."
#define ZT_MULTITAG_ARRAY_DEFAULTS_KEY                    @"multiTagArray"
#define ZT_MULTITAG_ALERTVIEW_WAITING_TIME  1
#define ZT_MULTITAG_ALERTVIEW_EMPTY_TITLE    @""

// BatchMode
#define ZT_BATCHMODE_NEGATIVE_VALUE      -1

// Firmware Update
#define ZT_FIRMWARE_UPDATE_DETAIL_INDEX         3
#define ZT_FIRMWARE_UPDATE_REPLACE_INDEX_START  0
#define ZT_FIRMWARE_UPDATE_REPLACE_INDEX_END    1
#define ZT_FIRMWARE_UPDATE_NAME_REPLACE         @"S"

// FriendlyName Support
#define ZT_FRIENDLYNAME_ARRAY_COUNT             1
#define ZT_FRIENDLYNAME_ARRAY_OBJECT_0          0
#define ZT_FRIENDLYNAME_ARRAY_OBJECT_1          1
#define ZT_FRIENDLYNAME_EMPTY_STRING            @""
#define ZT_FRIENDLYNAME_EMPTY_SPACE             @" "
#define ZT_FRIENDLYNAME_COMMA                   @","
#define ZT_FRIENDLYNAME_TAG_IDS                 @"TAG IDS"
#define ZT_FRIENDLYNAME_ITEM_NAME               @"ITEM NAME"

// Pre-Filter
#define ZT_PREFILTER_LENGTH_INTIAL_VALUE        @"16"

//Auto reconnect on app launch after app termination.
#define ZT_AUTO_CONNECT_CONFIG_IS_ENABLED  @"123RfidAutoReconnectionConfigIsEnabled"
#define ZT_AUTO_CONNECT_READER_ID  @"123RfidAutoReconnectionReaderID"
#define ZT_AUTO_CONNECT_TERMINATE_STATE  @"123RfidAutoReconnectionAppTerminateState"
#define ZT_AUTO_CONNECT_CONFIG_RESET_ID 0
#define ZT_TAG_LIST_COUNT_ZERO 0
#define ZT_PAIR_BY_CONNECT_ENABLE  @"123RfidPairByConnectEnabled"

//Advanced reader
#define SINGULATION_DEFAULTS_KEY        @"singulationChanged"
#define TAGREPORT_DEFAULTS_KEY          @"tagReportChanged"

//NFC
#define NFC_READ_MESSAGE @"Hold your iPhone near the Zebra device's NFC symbol to read."
#define NFC_READ_NON_SUPPORT_MESSAGE @"This device doesn't support NFC tag scanning."
#define NFC_READ_SESSION_INVALID @"Session Invalidated"
#define NFC_READ_SESSION_FOUND_NDEF @"Found a Zebra device."
#define NFC_READ_SESSION_FOUND_MORE_THAN_ONE @"Found more than one Zebra device."
#define NFC_PAIR_ICON @"nfc_communication"
#define NFC_TYPE_STRING @"application/zeb.bluetooth.ep.oob"
#define NFC_DEVICE_NAME_PREDICATE_FORMAT @"SELF like %@"
#define NFC_MESSAGE_TITLE_ERROR @"Error"
#define NFC_MESSAGE_RFD_TITLE @"RFD"
#define NFC_MESSAGE_DEVICE_FORMAT @"%@%@"
#define NFC_MESSAGE_PAYLOAD_INDEX_ONE 1
#define NFC_MESSAGE_INVALID_PAYLOAD @"Invalid payload message."

#define RFID40_FORMAT @"RFD40"
#define RFID90_FORMAT @"RFD90"
#define NFC_DEVICE_NAME_PREDICATE_BEGIN_WITH_FORMAT @"self BEGINSWITH '%@'"
#define NFC_DEVICE_NAME_PREDICATE_END_WITH_FORMAT @"SELF ENDSWITH %@"

// SCan Feature
#define ZT_SCAN_FEATURE_STRING_FORMAT        @"%@ %@"
#define ZT_SCAN_FEATURE_NOT_SUPPORT_MESSAGE   @"Scan feature is not supported for "

// Access Operations
#define ACCESS_OPERATION_READ_TIMEOUT       @"Access operation failed: Read timeout"
#define ACCESS_OPERATION_WRITE_TIMEOUT       @"Access operation failed: Write timeout"
#define ACCESS_OPERATION_LOCK_TIMEOUT       @"Access operation failed: Lock timeout"
#define ACCESS_OPERATION_KILL_TIMEOUT       @"Access operation failed: Kill timeout"

// Factory reset
#define ZT_ACTIVE_READER_KEY            @"activeReader"
// Batchmode
#define ZT_BATCHMODE_ENABLED_KEY            @"BatchModeEnabled"

// Scan symbology settings message
#define SYMBOLOGY_STRING_TEXT               @"Symbology"
#define BEEPER_STRING_TEXT                  @"Beeper"
#define GENERAL_FAILED_SETTINGS             @"Failed to apply settings"
#define GENERAL_SUCCESS_SETTINGS            @"Settings applied successfully"

// Firmware update warning message
#define FIRMWARE_UPDATE_WARNING_MESSAGE     @"Firmware update is not allowed while inventory is running"
#define FIRMWARE_UPDATE_BATTERY_LOW_MESSAGE @"Firmware update failed, the battery is critical"
#define FIRMWARE_UPDATE_TAG_LOCATE_WARNING  @"Firmware Update is not allowed while Taglocate is running in background"

// Device info defaults key
#define ZT_DEVICEINFO_DEFAULTS_KEY            @"DeviceInfo"
#define ZT_DEVICEINFO_API_CALL                @"ReaderDetailAPICall"
#define ZT_DEVICEINFO_API_CALL_VALUE                @"AppEngineCall"
#define ZT_DEVICEINFO_API_CALL_VALUE1                @"AssetDetailsCall"

// WIFI Settings
#define WIFI_SETTINGS_STORY_BOARD_NAME          @"WiFiSettingsStoryboard"
#define BASEWIFI_SETTINGS_BOARD_ID              @"BASEWIFI_SETTINGS_BOARD_ID"
#define WIFI_SETTINGS_BOARD_ID                  @"WIFI_SETTINGS_BOARD_ID"
#define CERTIFICATES_BOARD_ID                   @"CERTIFICATES_BOARD_ID"
#define ENDPOINT_BOARD_ID                       @"ENDPOINT_BOARD_ID"
#define ADD_NEW_ENDPOINT_BOARD_ID               @"ADD_NEW_ENDPOINT_BOARD_ID"
#define ENDPOINT_SET_BOARD_ID                   @"ENDPOINT_SET_BOARD_ID"
#define ENDPOINT_STATUS_BOARD_ID                       @"ENDPOINT_STATUS_BOARD_ID"

#define WIFI_STATUS_BOARD_ID                    @"WIFI_STATUS_BOARD_ID"
#define ADDPROFILE_POPUP_BOARD_ID               @"ADDPROFILE_POPUP_BOARD_ID"
#define SHAREPROFILE_POPUP_BOARD_ID             @"SHAREPROFILE_POPUP_BOARD_ID"
#define WIFI_SETTINGS_TITLE                     @"WiFi Settings"
#define WIFI_STATUS_TITLE                       @"WiFi Status"
#define EP_SETTINGS_TITLE                       @"EndPoint Settings"
#define EP_STATUS_TITLE                         @"EndPoint Status"

#define CERTIFICATES_STORY_BOARD_NAME           @"CertificatesStoryboard"
#define ADDCERTIFICATE_POPUP_BOARD_ID           @"ADDCERTIFICATE_POPUP_BOARD_ID"
#define CERTIFICATES_TITLE                      @"Certificates"
#define ZT_LOADING_STRING @"Loading..."
#define ZT_WIFI_START_EVENT   @"ScanStart"
#define ZT_WIFI_STOP_EVENT   @"ScanStop"
#define ZT_WIFI_CONNECT_EVENT   @"Connect"
#define ZT_WIFI_DISCONNECT_EVENT   @"Disconnect"
#define ZT_WIFI_OPERATION_FAILED_EVENT   @"Operation Failed"
#define ZT_WIFI_NOT_SUPPORT_MESSAGE   @"Wifi feature is not supported for "
#define ZT_CERTIFICATE_NOT_SUPPORT_MESSAGE @"Certificate feature is not supported for "
#define ZT_ENDPOINT_NOT_SUPPORT_MESSAGE @"Endpoint feature is not supported for "
#define ZT_LOGIN_NOT_SUPPORT_MESSAGE @"Login feature is not supported for "
#define ZT_DEVICE_AUTH_MESSAGE @"Device Authorization Required"


#define ENDPOINT_STORY_BOARD_NAME           @"EndPointConfigStoryboard"
#define ENDPOINTS_TITLE                     @"Endpoint Configuration"
#define LOGIN_STORY_BOARD_NAME              @"AdminLoginStoryboard"
#define LOGIN_BOARD_ID                      @"LOGIN_BOARD_ID"
#define CHANGEPW_BOARD_ID                   @"CHANGEPW_BOARD_ID"

// Regulatory
#define REGULATORY_DEFAULTS_KEY   @"RegulatoryDefailtsKey"
#define ANTENNA_CHANGE_DEFAULTS_KEY   @"AntennaDefailtsKey"
#define DP_CHANGE_DEFAULTS_KEY   @"DPDefailtsKey"
#define ANTENNA_DEFAULTS_VALUE   @"Internal"
#define ANTENNA_UPDATED_VALUE   @"Updated"
#define SELECTED_LP_DEFAULTS_KEY            @"SelectedLinkProfile"
#define PROFILE_OPENED_KEY                  @"isProfileVisited"
#define PROFILE_UPDATED_KEY                  @"isProfileUpdatedManual"

//Tamper tags
#define NON_TAMPER_TAGVALUE     @"0040"
#define NON_TAMPER_TAGVALUE1    @"0240"

//DPO Fix
#define DPO_DEFAULTS_KEY        @"DynamicPowers"

//Antenna messages
#define EMPTY_ERROR_IN_ANTENNA_SETTINGS     @"Empty fields in antenna settings"
#define INVALID_ERROR_IN_ANTENNA_SETTINGS     @"Invalid fields in antenna settings"

// Regulatory defaults
#define REGULATORY_CHECKBOX_KEY     @"Checkbox_status"
#endif /* __UI_CONFIG_H__ */

// Impinj Tag Settings
#define IMPINJ_TAG_CONFIG_STORYBOARD_NAME   @"ImpinjTagConfigStoryboard"
#define IMPINJ_BOARD_ID                @"IMPINJ_BOARD_ID"
#define IMPINJ_TAG_PROTECT_BOARD_ID     @"IMPINJ_TAG_PROTECT_BOARD_ID"
#define IMPINJ_INVENTORY_BOARD_ID       @"IMPINJ_INVENTORY_BOARD_ID"


