package com.cheusov;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.AbstractFileFilter;

import java.io.File;
import java.io.IOException;

/**
 * Created by Aleksey Cheusov on 4/28/17.
 */
class SymLinkFileFilter extends AbstractFileFilter {
    @Override
    public boolean accept(File file) {
        try {
            return FileUtils.isSymlink(file);
        } catch (IOException e) {
            return false;
        }
    }
}
