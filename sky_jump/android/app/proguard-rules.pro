# إعلانات AdMob تستخدم WorkManager، وقاعدة بياناته (Room) تُنشأ بالانعكاس.
# بدون هذه القواعد يحذفها R8 من نسخة الإصدار فتنهار اللعبة عند الفتح.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
