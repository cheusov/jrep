package com.cheusov;

import org.apache.commons.lang3.SystemUtils;

public class Utils {
    private static boolean withJNI =
            (System.getenv("JREP_NO_JNI") == null) && !SystemUtils.IS_OS_WINDOWS;

    static {
        if (withJNI)
            System.loadLibrary("jrep_jni");
    }

    private static native boolean isStdoutTTY();

    public static boolean isStdoutTTY_Any() {
        if (withJNI)
            return isStdoutTTY();
        else
            return true;
    }
}
