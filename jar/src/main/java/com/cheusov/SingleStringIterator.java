package com.cheusov;

import java.util.Iterator;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
class SingleStringIterator implements Iterator<String> {
    String str;

    public SingleStringIterator(String str) {
        this.str = str;
    }

    public boolean hasNext() {
        return str != null;
    }

    public String next() {
        String ret = str;
        str = null;
        return ret;
    }

    public void remove() {
        str = null;
    }
}
