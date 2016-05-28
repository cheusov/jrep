package com.cheusov;

import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
class JrepOptions extends Options {
    private List<Option> options = new ArrayList<Option>();

    public Collection getOptions() {
        return options;
    }

    public Options addOption(Option opt) {
        options.add(opt);
        return super.addOption(opt);
    }
}
