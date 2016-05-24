package com.cheusov;

import org.apache.commons.lang3.SystemUtils;

public class Utils {
    private static boolean osWindows = SystemUtils.IS_OS_WINDOWS;

    static {
        if (! osWindows)
            System.loadLibrary("jgrep_jni");
    }

    private static native boolean isStdoutTTY();

    private static boolean isStdoutTTY_Win() {
        return false;
    }

    public static boolean isStdoutTTY_Any() {
        if (osWindows)
            return isStdoutTTY_Win();
        else
            return isStdoutTTY();
    }
}
