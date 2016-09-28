package com.cheusov;

import com.google.re2j.Matcher;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
class JrepRe2jMatcher implements JrepMatchResult {
    Matcher matcher;

    public JrepRe2jMatcher(Matcher matcher){
        this.matcher = matcher;
    }

    public int start() {
        return matcher.start();
    }

    public int start(int i) {
        return matcher.start(i);
    }

    public int end() {
        return matcher.end();
    }

    public int end(int i) {
        return matcher.end(i);
    }

    public String group() {
        return matcher.group();
    }

    public String group(int i) {
        return matcher.group(i);
    }

    public int groupCount() {
        return matcher.groupCount();
    }

    public boolean find() {
        return matcher.find();
    }

    public boolean find(int pos) {
        return matcher.find(pos);
    }

    public boolean matches() {
        return matcher.matches();
    }
}
