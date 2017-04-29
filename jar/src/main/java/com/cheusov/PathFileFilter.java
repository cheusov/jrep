package com.cheusov;

import org.apache.commons.io.filefilter.AbstractFileFilter;

import java.io.File;

/**
 * Created by Aleksey Cheusov on 4/28/17.
 */
class PathFileFilter extends AbstractFileFilter {
    private String path;

    public PathFileFilter(String path) {
        this.path = path;
    }

    @Override
    public boolean accept(File file) {
        return path.equals(file.getPath());
    }
}
