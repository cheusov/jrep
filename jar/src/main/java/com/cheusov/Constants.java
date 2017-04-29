package com.cheusov;

/**
 * Created by Aleksey Cheusov on 4/28/17.
 */
final class Constants {
    public static final String USAGE_MESSAGE = "Usage: jrep [OPTIONS]... PATTERN [FILES...]";
    public static final String HELP_REF_MESSAGE = "Try 'jrep --help' for more information.";
    public static final String OPTION_GROUP_REGEXP_SELECTION_AND_INTERPRETATION = "Regexp selection and interpretation:";
    public static final String OPTION_GROUP_MISCELLANEOUS = "Miscellaneous:";
    public static final String OPTION_GROUP_OUTPUT_CONTROL = "Output control:";
    public static final String OPTION_GROUP_CONTEXT_CONTROL = "Context control:";
    public static final String HEADER_MESSAGE = "Search for PATTERN in each FILE or standard input. " +
            "PATTERN is, by default, a Java regular expression (java.lang.regex).\n" +
            "Example: jrep -i 'hello world' menu.h main.c";
    public static final String FOOTER_MESSAGE = "When FILE is -, read standard input.  With no FILE, read . " +
            "if a command-line -r is given, - otherwise.  If fewer than two FILEs are given, assume -h. " +
            "Exit status is 0 if any line is selected, 1 otherwise; if any error occurs and -q is not given, " +
            "the exit status is 2.\nJrep home page: <https://github.com/cheusov/jrep>";
}
