package com.cheusov;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
class JrepPattern {
    public static enum RE_ENGINE_TYPE {
        JAVA, RE2J
    }

    Pattern patternJava;
    com.google.re2j.Pattern patternRe2;

    public JrepPattern(Pattern pattern) {
        patternJava = pattern;
    }

    public JrepPattern(com.google.re2j.Pattern pattern) {
        patternRe2 = pattern;
    }

    static JrepPattern compile(RE_ENGINE_TYPE engineType, String regex) {
        switch (engineType) {
            case JAVA:
                return new JrepPattern(Pattern.compile(regex));
            case RE2J:
                return new JrepPattern(com.google.re2j.Pattern.compile(regex));
        }

        return null;
    }

    public JrepMatchResult matcher(String text){
        if (patternJava != null)
            return new JrepJdkMatcher(patternJava.matcher(text));
        if (patternRe2 != null)
            return new JrepRe2jMatcher(patternRe2.matcher(text));

        return null;
    }
}
