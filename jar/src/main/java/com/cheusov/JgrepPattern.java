package com.cheusov;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
public class JgrepPattern {
    public static enum RE_ENGINE_TYPE {
        JAVA, RE2J
    }

    Pattern patternJava;
    com.google.re2j.Pattern patternRe2;

    public JgrepPattern(Pattern pattern) {
        patternJava = pattern;
    }

    public JgrepPattern(com.google.re2j.Pattern pattern) {
        patternRe2 = pattern;
    }

    static JgrepPattern compile(RE_ENGINE_TYPE engineType, String regex) {
        switch (engineType) {
            case JAVA:
                return new JgrepPattern(Pattern.compile(regex));
            case RE2J:
                return new JgrepPattern(com.google.re2j.Pattern.compile(regex));
        }

        return null;
    }

    public JgrepMatcher matcher(String text){
        if (patternJava != null)
            return new JgrepMatcher(patternJava.matcher(text));
        if (patternRe2 != null)
            return new JgrepMatcher(patternRe2.matcher(text));

        return null;
    }
}
