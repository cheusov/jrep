package com.cheusov;

public class Utils {
    static {
        System.loadLibrary("jgrep_jni");
    }

    public static native boolean isStdoutTTY();
}
