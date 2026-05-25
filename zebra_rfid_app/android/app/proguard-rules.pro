# Zebra RFID SDK — prevent R8 from stripping constructors used via reflection
-keep class com.zebra.rfid.api3.** { *; }
-keep class com.zebra.scannercontrol.** { *; }
-dontwarn com.zebra.rfid.api3.**
-dontwarn com.zebra.scannercontrol.**
