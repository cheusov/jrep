package com.cheusov;

import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import java.io.PrintWriter;
import java.util.Collection;

/**
 * Created by Aleksey Cheusov on 5/14/16.
 */
class JrepHelpFormatter extends HelpFormatter {
    public void printUsage(PrintWriter pw, int width, String app, Options options) {
    }

    public void printUsage(PrintWriter pw, int width, String app) {
    }

    protected StringBuffer renderOptions(StringBuffer sb, int width, Options options, int leftPad, int descPad) {
        final String lpad = createPadding(leftPad);
        final String dpad = createPadding(descPad);

        StringBuffer optBuf;

        Collection<Option> optList = options.getOptions();

        int max = 25;

        for (Option option : optList) {
            optBuf = new StringBuffer(8);

            if (option.getOpt() == null) {
                optBuf.append(lpad).append("   " + getLongOptPrefix()).append(option.getLongOpt());
            } else {
                optBuf.append(lpad).append(getOptPrefix()).append(option.getOpt());

                if (option.hasLongOpt())
                    optBuf.append(',').append(getLongOptPrefix()).append(option.getLongOpt());
            }

            if (option.hasArg()) {
                if (option.hasArgName())
                    optBuf.append(" <").append(option.getArgName()).append(">");
                else
                    optBuf.append(' ');
            }

            if (optBuf.length() < max)
                optBuf.append(createPadding(max - optBuf.length()));

            optBuf.append(dpad);

            int nextLineTabStop = max + descPad;

            if (option.getDescription() != null)
                optBuf.append(option.getDescription());

            renderWrappedText(sb, width, nextLineTabStop, optBuf.toString());

            sb.append(getNewLine());
        }

        return sb;
    }
}
