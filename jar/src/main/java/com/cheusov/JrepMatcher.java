package com.cheusov;

import java.util.regex.MatchResult;
import java.util.regex.Matcher;

import static com.cheusov.JrepPattern.RE_ENGINE_TYPE.*;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
class JrepMatcher implements MatchResult {
    Matcher matcherJava;
    com.google.re2j.Matcher matcherRe2;

    public JrepMatcher(Matcher matcher){
        this.matcherJava = matcher;
    }

    public JrepMatcher(com.google.re2j.Matcher matcher){
        this.matcherRe2 = matcher;
    }

    public int start() {
        if (matcherJava != null)
            return matcherJava.start();
        if (matcherRe2 != null)
            return matcherRe2.start();

        return -1;
    }

    public int start(int i) {
        if (matcherJava != null)
            return matcherJava.start(i);
        if (matcherRe2 != null)
            return matcherRe2.start(i);

        return -1;
    }

    public int end() {
        if (matcherJava != null)
            return matcherJava.end();
        if (matcherRe2 != null)
            return matcherRe2.end();

        return -1;
    }

    public int end(int i) {
        if (matcherJava != null)
            return matcherJava.end(i);
        if (matcherRe2 != null)
            return matcherRe2.end(i);

        return -1;
    }

    public String group() {
        if (matcherJava != null)
            return matcherJava.group();
        if (matcherRe2 != null)
            return matcherRe2.group();

        return null;
    }

    public String group(int i) {
        if (matcherJava != null)
            return matcherJava.group(i);
        if (matcherRe2 != null)
            return matcherRe2.group(i);

        return null;
    }

    public int groupCount() {
        if (matcherJava != null)
            return matcherJava.groupCount();
        if (matcherRe2 != null)
            return matcherRe2.groupCount();

        return 0;
    }

    public boolean find() {
        if (matcherJava != null)
            return matcherJava.find();
        if (matcherRe2 != null)
            return matcherRe2.find();

        return false;
    }

    public boolean find(int pos) {
        if (matcherJava != null)
            return matcherJava.find(pos);
        if (matcherRe2 != null)
            return matcherRe2.find(pos);

        return false;
    }

    public boolean matches() {
        if (matcherJava != null)
            return matcherJava.matches();
        if (matcherRe2 != null)
            return matcherRe2.matches();

        return false;
    }
}
