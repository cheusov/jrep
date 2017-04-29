package com.cheusov;

import org.apache.commons.cli.Option;

/**
 * Created by Aleksey Cheusov on 4/28/17.
 */
class JrepOptionsGroups {
    public JrepOptions[] optionGroups = {null, null, null, null};

    public JrepOptionsGroups() {
        initOptions();
    }

    public JrepOptions getOptions() {
        JrepOptions options = new JrepOptions();
        for (int i = 0; i < optionGroups.length; ++i)
            for (Object obj : optionGroups[i].getOptions())
                options.addOption((Option) obj);

        return options;
    }

    private void initOptions() {
        JrepOptions options;

        ///////////// group 0 /////////////
        options = optionGroups[0] = new JrepOptions();

        options.addOption("E", "extended-regexp", null, "Ignored.");
        options.addOption("F", "fixed-strings", null, "Interpret pattern as a set of fixed strings.");
        options.addOption("G", "basic-regexp", null, "Ignored.");
        options.addOption("P", "perl-regexp", null, "Ignored.");
        options.addOption("2", null, null, "Same as '--re-engine re2j'.");
        options.addOption(null, "re-engine", "ENGINE", "Specify a RE engine. ENGINE is either " +
                "'java' (java.util.regex) or 're2j' (com.google.re2j). The default is 'java'.");
        options.addOption("e", "regexp", "PATTERN", "Specify a pattern used during the search of the input: an input line is " +
                "selected if it matches any of the specified patterns. " +
                "This option is most useful when multiple -e options are used to specify multiple patterns, " +
                "or when a pattern begins with a dash ('-').");
        options.addOption("f", "file", "FILE", "Obtain PATTERN from FILE.");
        options.addOption("i", "ignore-case", null, "Perform case insensitive matching. By default, " +
                "grep is case sensitive.");
        options.addOption("w", "word-regexp", null, "Force PATTERN to match only whole words.");
        options.addOption("x", "line-regexp", null, "Only input lines selected against an entire fixed string " +
                "or regular expression are considered to be matching lines.");

        ///////////// group 1 /////////////
        options = optionGroups[1] = new JrepOptions();

        options.addOption("s", "no-messages", null, "Suppress error messages");
        options.addOption("v", "invert-match", null, "Selected lines are those not matching any of " +
                "the specified patterns.");
        options.addOption("V", "version", null, "Display version information and exit.");
        options.addOption(null, "help", null, "Display this help text and exit.");

        ///////////// group 2 /////////////
        options = optionGroups[2] = new JrepOptions();

        options.addOption("m", "max-count", "NUM", "Stop after NUM matches.");
        options.addOption("n", "line-number", null, "Each output line is preceded by its relative line number " +
                "in the file, starting at line 1. The line number counter is reset for each file processed. " +
                "This option is ignored if -c, -L, -l, or -q is specified.");
        options.addOption(null, "line-buffered", null, "Flush output on every line.");
        options.addOption("H", "with-filename", null, "Print the file name for each match.");
        options.addOption("h", "no-filename", null, "Never print filename headers (i.e. filenames) with output lines.");
        options.addOption(null, "label", "LABEL", "Use LABEL as the standard input file name prefix.");
        options.addOption("o", "only-matching", null, "Print each match, but only the match, not the entire line.");
        options.addOption("O", "output-format", "FORMAT", "Same as -o but FORMAT specifies the output format.");
        options.addOption(null, "marker-start", "MARKER", "Marker for the beginning of matched substring.");
        options.addOption(null, "marker-end", "MARKER", "Marker for the end of matched substring.");
        options.addOption("q", "quiet", null, "Quiet. Nothing shall be written to the standard output," +
                " regardless of matching lines. Exit with zero status if an input line is selected.");
        options.addOption(null, "silent", null, "Same as --quiet.");
        options.addOption("8", null, null, "Match the whole file content at once.");
        options.addOption("d", "directories", "ACTION", "How to handle directories; " +
                "ACTION is 'read', 'recurse', or 'skip'.");
        options.addOption("r", "recursive", null, "Like --directories=recurse.");
        options.addOption("R", "dereference-recursive", null, "Likewise, but follow all symlinks.");
        options.addOption(null, "include", "FILE_PATTERN", "Search only files that match FILE_PATTERN pattern.");
        options.addOption(null, "exclude", "FILE_PATTERN", "Skip files matching FILE_PATTERN.");
        options.addOption(null, "exclude-from", "FILE", "Skip files whose base name matches any of" +
                " the file-name globs read from FILE (using wildcard matching as described under --exclude).");
        options.addOption("L", "files-without-match", null, "Only the names of files not containing selected lines " +
                "are written to standard output. Pathnames are listed once per file searched. " +
                "If the standard input is searched, the string “(standard input)” is written.");
        options.addOption("l", "files-with-matches", null, "Only the names of files containing selected lines " +
                "are written to standard output. grep will only search a file until a match has been found, " +
                "making searches potentially less expensive. Pathnames are listed once per file searched. " +
                "If the standard input is searched, the string “(standard input)” is written.");
        options.addOption("c", "count", null, "Only a count of selected lines is written to standard output.");

        ///////////// group 3 /////////////
        options = optionGroups[3] = new JrepOptions();

        options.addOption("B", "before-context", "NUM", "Print NUM lines of leading context.");
        options.addOption("A", "after-context", "NUM", "Print NUM lines of trailing context.");
        options.addOption("C", "context", "NUM", "Print NUM lines of output context.");
        options.addOption(null, "color", "WHEN", "Use markers to highlight the matching strings; " +
                "WHEN is 'always', 'never' or 'auto' (the default).");
        options.addOption(null, "colour", "WHEN", "Same as --color.");
    }

}
