package com.cheusov;

import java.util.regex.MatchResult;
import java.util.regex.Matcher;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
interface JrepMatchResult extends MatchResult {
    boolean find();
    boolean find(int pos);
    boolean matches();
}
