// Copyright 2016 Aleksey Cheusov <vle@gmx.net>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.cheusov;

import org.apache.commons.cli.*;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.filefilter.*;
import org.apache.commons.lang3.SystemUtils;
import org.apache.commons.lang3.tuple.Pair;

import java.io.*;
import java.util.*;

/**
 * Created by Aleksey Cheusov on 4/24/16.
 */
public class Jrep {

    private static final String OPTION_GROUP_REGEXP_SELECTION_AND_INTERPRETATION = "Regexp selection and interpretation:";
    private static final String OPTION_GROUP_MISCELLANEOUS = "Miscellaneous:";
    private static final String OPTION_GROUP_OUTPUT_CONTROL = "Output control:";
    private static final String OPTION_GROUP_CONTEXT_CONTROL = "Context control:";

    private static enum Directories {
        RECURSE,
        SKIP,
        READ
    }

    private static final String USAGE_MESSAGE = "Usage: jrep [OPTIONS]... PATTERN [FILES...]";
    private static final String HEADER_MESSAGE = "Search for PATTERN in each FILE or standard input. " +
            "PATTERN is, by default, a Java regular expression (java.lang.regex).\n" +
            "Example: jrep -i 'hello world' menu.h main.c";
    private static final String FOOTER_MESSAGE = "When FILE is -, read standard input.  With no FILE, read . " +
            "if a command-line -r is given, - otherwise.  If fewer than two FILEs are given, assume -h. " +
            "Exit status is 0 if any line is selected, 1 otherwise; if any error occurs and -q is not given, " +
            "the exit status is 2.\nJrep home page: <https://github.com/cheusov/jrep>";

    private static JrepOptions[] optionGroups = {null, null, null, null};
    private static JrepOptions options;

    private static List<String> regexps = new ArrayList<String>();
    private static ArrayList<JrepPattern> patterns = new ArrayList<JrepPattern>();
    private static int exitStatus = 1;

    private static boolean inverseMatch = false;
    private static boolean outputFilename = false;
    private static boolean opt_o = false;
    private static boolean wholeContent = false;
    private static boolean opt_L = false;
    private static boolean opt_i = false;
    private static boolean opt_h = false;
    private static boolean opt_H = false;
    private static boolean opt_F = false;
    private static boolean opt_c = false;
    private static boolean opt_n = false;
    private static boolean opt_x = false;
    private static boolean opt_q = false;
    private static boolean opt_s = false;
    private static boolean opt_w = false;
    private static boolean opt_line_buffered = false;
    private static int opt_m = 2000000000;
    private static boolean prefixWithFilename = false;
    private static int opt_B = 0;
    private static int opt_A = 0;
    private static String opt_O = null;
    private static JrepPattern.RE_ENGINE_TYPE opt_re_engine = JrepPattern.RE_ENGINE_TYPE.JAVA;

    private static Directories opt_directories = Directories.READ;

    private static String label = "(standard input)";
    private static OrFileFilter orExcludeFileFilter = new OrFileFilter();
    private static OrFileFilter orIncludeFileFilter = new OrFileFilter();
    private static AndFileFilter fileFilter = new AndFileFilter();

    private static String colorEscStart;
    private static String colorEscEnd;

    private static boolean isStdoutTTY = false;

    private static String encoding = System.getProperty("file.encoding");

    private static boolean withJNI =
            (System.getenv("JREP_NO_JNI") == null) && !SystemUtils.IS_OS_WINDOWS;

    static {
        if (withJNI)
            System.loadLibrary("jrep_jni");

        fileFilter.addFileFilter(orIncludeFileFilter);
        fileFilter.addFileFilter(new NotFileFilter(orExcludeFileFilter));

        orExcludeFileFilter.addFileFilter(FalseFileFilter.FALSE);

        isStdoutTTY = isStdoutTTY_Any();

        String colorEscSequence = System.getenv("JREP_COLOR");
        if (colorEscSequence == null)
            colorEscSequence = System.getenv("GREP_COLOR");

        if (colorEscSequence != null) {
            colorEscStart = ("\033[" + colorEscSequence + "m");
            colorEscEnd = "\033[1;0m";
        }

        initOptions();
    }

    public static boolean isStdoutTTY_Any() {
        if (withJNI)
            return Utils.isStdoutTTY();
        else
            return true;
    }

    private static class SymLinkFileFilter extends AbstractFileFilter {
        @Override
        public boolean accept(File file) {
            try {
                return FileUtils.isSymlink(file);
            } catch (IOException e) {
                return false;
            }
        }
    }

    private static class PathFileFilter extends AbstractFileFilter {
        private String path;

        public PathFileFilter(String path) {
            this.path = path;
        }

        @Override
        public boolean accept(File file) {
            return path.equals(file.getPath());
        }
    }

    private static void println(String line) {
        if (!opt_q) {
            System.out.println(line);
            if (opt_line_buffered)
                System.out.flush();
        }
    }

    private static void printlnWithPrefix(String filename, String line, int lineNumber, char separator) {
        String prefix1 = "";
        if (prefixWithFilename)
            prefix1 = filename + separator;
        String prefix = prefix1;
        if (opt_n)
            prefix = prefix + lineNumber + separator;

        println(prefix + line);
    }

    private static String getLineToPrint(String line, List<Pair<Integer, Integer>> startend) {
        StringBuilder sb = new StringBuilder();
        Collections.sort(startend,
                new Comparator<Pair<Integer, Integer>>() {
                    public int compare(Pair<Integer, Integer> a, Pair<Integer, Integer> b) {
                        if (a.getLeft() < b.getLeft())
                            return -1;
                        if (a.getLeft() > b.getLeft())
                            return 1;
                        return b.getRight() - a.getRight();
                    }
                });

        int prev = 0;
        for (Pair<Integer, Integer> p : startend) {
            int start = p.getLeft();
            int end = p.getRight();
            if (end < prev)
                continue;
            if (start < prev)
                start = prev;
            sb.append(line.substring(prev, start));
            if (start < end) {
                sb.append(colorEscStart);
                sb.append(line.substring(start, end));
                sb.append(colorEscEnd);
            }
            prev = end;
        }

        return (sb.toString() + line.substring(prev));
    }

    private static StringBuilder[] extractCurlyBraces(String text, int pos){
        StringBuilder[] ret = {null, null};

        StringBuilder sbLetters = ret[0] = new StringBuilder();
        StringBuilder sbDigits  = ret[1] = new StringBuilder();

        int length = text.length();
        for (; pos < length; ++pos) {
            char c = text.charAt(pos);
            if (c == '}')
                break;

            if (c >= '0' && c <= '9') {
                sbDigits.append(c);
            } else if (c == 't' || c == 'n' || c == 'N' || c == 's') {
                sbLetters.append(c);
            } else {
                throw new IllegalArgumentException("Unexpected `" + c + " in -O argument at position " + pos);
            }
        }

        return ret;
    }

    private static String getOutputString(String line, JrepMatcher match){
        if (opt_O == null)
            return line.substring(match.start(), match.end());

        StringBuilder b = new StringBuilder();
        int len = opt_O.length();
        for (int i = 0; i < len; ++i){
            char c = opt_O.charAt(i);
            if (c != '$') {
                b.append(c);
            } else {
                if (i + 1 == len)
                    throw new IllegalArgumentException("Unexpected `$` in -O argument: `" + opt_O + "`");
                char nc = opt_O.charAt(i + 1);
                if (nc == '$')
                    b.append('$');
                else if (nc == '{') {
                    StringBuilder[] ld;
                    i += 1;
                    ld = extractCurlyBraces(opt_O, i + 1);
                    StringBuilder l = ld[0];
                    StringBuilder d = ld[1];
                    int sumlen = d.length() + l.length();
                    i += sumlen; // +1 due to '}'
                    int groupNum = Integer.valueOf(d.toString());

                    String group = match.group(groupNum);
                    if (group == null)
                        group = "";

                    for (int j = 0; j < l.length(); ++j){
                        char lc = l.charAt(j);
                        switch (lc) {
                            case 'n':
                                group = group.replaceAll("\\\\", "\\\\").replaceAll("\n", "\\\\n");
                                break;
                            case 'N':
                                group = group.replaceAll("\n", " ");
                                break;
                            case 's':
                                group = group.replaceAll("\\s+", " ");
                                break;
                            case 't':
                                group = group.trim();
                                break;
                        }
                    }
                    b.append(group);
                } else if (nc >= '0' && nc <= '9') {
                    String group = match.group(nc - '0');
                    if (group == null)
                        group = "";

                    b.append(group);
                } else {
                    throw new IllegalArgumentException("Illegal `$" + nc + "` in -O argument: `" + opt_O + "`");
                }

                ++i;
            }
        }

        return b.toString();
    }

    private static void processFile(InputStream in, String filename) throws IOException {
        Iterator<String> it;
        if (wholeContent) {
            String fileContent = IOUtils.toString(in, encoding);
            it = Arrays.asList(fileContent).iterator();
        } else {
            it = IOUtils.lineIterator(in, encoding);
        }

        int matchCount = 0;
        List<Pair<Integer, Integer>> startend = null;
        int lineNumber = 0;
        int lastMatchedLineNumber = 0;
        Map<Integer, String> lines = new HashMap<Integer, String>();
        while (it.hasNext()) {
            ++lineNumber;

            String line = (String) it.next();
            if (opt_B > 0) {
                lines.put(lineNumber, line);
                lines.remove(lineNumber - opt_B - 1);
            }

            boolean matched = false;
            boolean nextFile = false;

            if (!inverseMatch && !outputFilename && !opt_o && !opt_L && !opt_c)
                startend = new ArrayList<Pair<Integer, Integer>>();

            String lineToPrint = null;
            for (JrepPattern pattern : patterns) {
                int pos = 0;
                JrepMatcher m = pattern.matcher(line);

                boolean nextLine = false;
                while (m.find(pos) ^ inverseMatch) {
                    matched = true;

                    if (exitStatus == 1)
                        exitStatus = 0;

                    if (outputFilename) {
                        nextFile = true;
                        println(filename);
                        break;
                    } else if (opt_c) {
                        nextLine = true;
                        break;
                    } else if (opt_L) {
                        nextFile = true;
                        break;
                    } else if (inverseMatch) {
                        nextLine = true;
                        lineToPrint = line;
                        break;
                    } else if (opt_o) {
                        printlnWithPrefix(filename, getOutputString(line, m), lineNumber, ':');
                    } else if (colorEscStart == null) {
                        nextLine = true;
                        break;
                    } else {
                        startend.add(Pair.of(m.start(), m.end()));
                    }
                    pos = m.end();
                }

                if (nextFile || nextLine)
                    break;
            }

            if (matched) {
                ++matchCount;
                if (matchCount == opt_m)
                    nextFile = true;

                if (!inverseMatch && !outputFilename && !opt_o && !opt_L && !opt_c)
                    lineToPrint = getLineToPrint(line, startend);
            }

            if (lineToPrint != null) {
                for (int prevLineNumber = lineNumber - opt_B; prevLineNumber < lineNumber; ++prevLineNumber) {
                    String prevLine = lines.get(prevLineNumber);
                    if (prevLine != null) {
                        lines.remove(prevLineNumber);
                        printlnWithPrefix(filename, prevLine, prevLineNumber, '-');
                    }
                }

                lastMatchedLineNumber = lineNumber;

                lines.remove(lineNumber);
                printlnWithPrefix(filename, lineToPrint, lineNumber, ':');
            } else if (lastMatchedLineNumber > 0 && lastMatchedLineNumber + opt_A >= lineNumber) {
                lines.remove(lineNumber);
                printlnWithPrefix(filename, line, lineNumber, '-');
            }

            if (nextFile)
                break;
        }

        if (opt_L && matchCount == 0)
            println(filename);

        if (opt_c)
            printlnWithPrefix(filename, "" + matchCount, lineNumber, ':');
    }

    private static void initOptions() {
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
        options.addOption(null, "directories", "ACTION", "How to handle directories; " +
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

        ///////////////////////////////////
        options = new JrepOptions();

        for (int i = 0 ; i < optionGroups.length; ++i)
            for (Object obj : optionGroups[i].getOptions())
                options.addOption((Option) obj);
    }

    private static String[] handleOptions(String[] args) throws ParseException, IOException {
        CommandLineParser parser = new PosixParser();
        CommandLine cmd = parser.parse(options, args);

        inverseMatch = cmd.hasOption("v");
        outputFilename = cmd.hasOption("l");
        opt_O = cmd.getOptionValue("O");
        opt_o = cmd.hasOption("o") || (opt_O != null);
        wholeContent = cmd.hasOption("8");
        opt_L = cmd.hasOption("L");
        opt_i = cmd.hasOption("i");
        opt_h = cmd.hasOption("h");
        opt_H = cmd.hasOption("H");
        opt_F = cmd.hasOption("F");
        opt_c = cmd.hasOption("c");
        opt_n = cmd.hasOption("n");
        opt_x = cmd.hasOption("x");

        boolean optBool = cmd.hasOption("R");
        opt_directories = (optBool || cmd.hasOption("r") ? Directories.RECURSE : Directories.READ);
        if (!optBool)
            orExcludeFileFilter.addFileFilter(new SymLinkFileFilter());

        opt_s = cmd.hasOption("s");
        opt_q = cmd.hasOption("q") || cmd.hasOption("silent");
        opt_w = cmd.hasOption("w");
        opt_line_buffered = cmd.hasOption("line-buffered");

        String[] optArray = cmd.getOptionValues("e");
        if (optArray != null && optArray.length != 0) {
            for (String regexp : optArray)
                regexps.add(regexp);
        }

        optArray = cmd.getOptionValues("include");
        if (optArray != null && optArray.length != 0) {
            for (String globPattern : optArray)
                orIncludeFileFilter.addFileFilter(new WildcardFileFilter(globPattern));
        } else {
            orIncludeFileFilter.addFileFilter(TrueFileFilter.TRUE);
        }

        optArray = cmd.getOptionValues("exclude");
        if (optArray != null && optArray.length != 0) {
            for (String globPattern : optArray) {
                if (globPattern.startsWith(".") || globPattern.startsWith("/"))
                    orExcludeFileFilter.addFileFilter(new PathFileFilter(globPattern));
                else
                    orExcludeFileFilter.addFileFilter(new WildcardFileFilter(globPattern));
            }
        }

        String optStr = cmd.getOptionValue("exclude-from");
        if (optStr != null) {
            Iterator<String> it = IOUtils.lineIterator(new FileInputStream(optStr), encoding);
            while (it.hasNext()) {
                String globPattern = it.next();

                if (globPattern.startsWith(".") || globPattern.startsWith("/"))
                    orExcludeFileFilter.addFileFilter(new PathFileFilter(globPattern));
                else
                    orExcludeFileFilter.addFileFilter(new WildcardFileFilter(globPattern));
            }
        }

        optStr = cmd.getOptionValue("f");
        if (optStr != null) {
            Iterator<String> it = IOUtils.lineIterator(new FileInputStream(optStr), encoding);
            while (it.hasNext()) {
                regexps.add(it.next());
            }
        }

        optStr = cmd.getOptionValue("m");
        if (optStr != null)
            opt_m = Integer.valueOf(optStr);

        optStr = cmd.getOptionValue("label");
        if (optStr != null)
            label = optStr;

        optStr = cmd.getOptionValue("marker-start");
        if (optStr != null)
            colorEscStart = optStr;
        optStr = cmd.getOptionValue("marker-end");
        if (optStr != null)
            colorEscEnd = optStr;

        optStr = cmd.getOptionValue("A");
        if (optStr != null)
            opt_A = Integer.valueOf(optStr);

        optStr = cmd.getOptionValue("B");
        if (optStr != null)
            opt_B = Integer.valueOf(optStr);

        optStr = cmd.getOptionValue("C");
        if (optStr != null)
            opt_A = opt_B = Integer.valueOf(optStr);

        optStr = cmd.getOptionValue("color");
        if (optStr == null)
            optStr = cmd.getOptionValue("colour");

        if (optStr == null || optStr.equals("auto")) {
            if (! isStdoutTTY)
                colorEscStart = null;
        } else if (optStr.equals("always")) {
        } else if (optStr.equals("never")) {
            colorEscStart = null;
        } else {
            throw new IllegalArgumentException("Illegal argument `" + optStr + "` for option --color");
        }

        optStr = cmd.getOptionValue("re-engine");
        if (optStr == null) {
        } else if (optStr.equals("java")) {
            opt_re_engine = JrepPattern.RE_ENGINE_TYPE.JAVA;
        } else if (optStr.equals("re2j")) {
            opt_re_engine = JrepPattern.RE_ENGINE_TYPE.RE2J;
        } else {
            throw new IllegalArgumentException("Illegal argument `" + optStr + "` for option --re-engine");
        }

        optStr = cmd.getOptionValue("directories");
        if (optStr == null) {
        } else if (optStr.equals("skip")) {
            opt_directories = Directories.SKIP;
        } else if (optStr.equals("read")) {
            opt_directories = Directories.READ;
        } else if (optStr.equals("recurse")) {
            opt_directories = Directories.RECURSE;
        } else {
            throw new IllegalArgumentException("Illegal argument `" + optStr + "` for option --directories");
        }

        if (cmd.hasOption("2"))
            opt_re_engine = JrepPattern.RE_ENGINE_TYPE.RE2J;

        if (cmd.hasOption("help")) {
            printHelp(options);
            System.exit(0);
        }

        if (cmd.hasOption("V")) {
            System.out.println("jrep-" + System.getenv("JREP_VERSION"));
            System.exit(0);
        }

        return cmd.getArgs();
    }

    private static void printHelp(Options options) {
        JrepHelpFormatter formatter = new JrepHelpFormatter();
        formatter.setLeftPadding(2);

        PrintWriter pw = new PrintWriter(System.out);

        final int width = formatter.getWidth();
        final int lpad = formatter.getLeftPadding();
        final int dpad = formatter.getDescPadding();
//        formatter.printHelp(USAGE_MESSAGE, options);
        formatter.printWrapped(pw, width, USAGE_MESSAGE);
        formatter.printWrapped(pw, width, HEADER_MESSAGE);
        formatter.printWrapped(pw, width, "");

        formatter.printWrapped(pw, width, OPTION_GROUP_REGEXP_SELECTION_AND_INTERPRETATION);
        formatter.printHelp(pw, width, " ", null, optionGroups[0], lpad, dpad, null);

        formatter.printWrapped(pw, width, OPTION_GROUP_MISCELLANEOUS);
        formatter.printHelp(pw, width, " ", null, optionGroups[1], lpad, dpad, null);

        formatter.printWrapped(pw, width, OPTION_GROUP_OUTPUT_CONTROL);
        formatter.printHelp(pw, width, " ", null, optionGroups[2], lpad, dpad, null);

        formatter.printWrapped(pw, width, OPTION_GROUP_CONTEXT_CONTROL);
        formatter.printHelp(pw, width, " ", null, optionGroups[3], lpad, dpad, null);

        formatter.printWrapped(pw, formatter.getWidth(), FOOTER_MESSAGE);

        pw.flush();
//        formatter.printHelp(USAGE_MESSAGE, HEADER_MESSAGE, options, FOOTER_MESSAGE, false);
    }

    private static void sanityCheck() {
        if (regexps.isEmpty()) {
            System.err.println("pattern should be specified");
            System.exit(2);
        }
    }

    private static String[] handleFreeArgs(String[] args) {
        if (!regexps.isEmpty())
            return args;

        if (args.length > 0)
            regexps.add(args[0]);

        return Arrays.copyOfRange(args, 1, args.length);
    }

    private static void init(String[] args) {
        if (opt_F) {
            for (int i = 0; i < regexps.size(); ++i)
                regexps.set(i, "\\Q" + regexps.get(i) + "\\E");
        }
        if (opt_x) {
            for (int i = 0; i < regexps.size(); ++i)
                regexps.set(i, "(?m:^(?:" + regexps.get(i) + ")$)");
        }
        if (opt_w) {
            for (int i = 0; i < regexps.size(); ++i)
                regexps.set(i, "\\b(?:" + regexps.get(i) + ")\\b");
        }

        if (opt_i) {
            for (int i = 0; i < regexps.size(); ++i)
                regexps.set(i, "(?i:" + regexps.get(i) + ")");
        }

        for (int i = 0; i < regexps.size(); ++i)
            patterns.add(JrepPattern.compile(opt_re_engine, regexps.get(i)));

        prefixWithFilename = (opt_H || opt_directories == Directories.RECURSE || args.length > 1) && !opt_h;
    }

    private static final String[] stdinFilenames = {"-"};

    private static void grep(String[] args) throws Exception {
        if (args.length == 0)
            args = stdinFilenames;

        for (String fileOrDir : args) {
            try {
                Iterator fileIterator;
                File file = new File(fileOrDir);
                boolean isDir = false;
                if (opt_directories != Directories.READ)
                    isDir = file.isDirectory();

                if (isDir && opt_directories == Directories.SKIP)
                    continue;

                if (isDir && opt_directories == Directories.RECURSE) {
                    fileIterator = FileUtils.iterateFiles(file, fileFilter, DirectoryFileFilter.DIRECTORY);
                } else {
                    fileIterator = Arrays.asList(fileOrDir).iterator();
                }

                while (fileIterator.hasNext()) {
                    Object fileObj = fileIterator.next();
                    String filename;
                    if (fileObj instanceof String)
                        filename = (String) fileObj;
                    else
                        filename = ((File) fileObj).getPath().replaceAll("^^[.]/", "");

                    if (filename.equals("-")) {
                        processFile(System.in, label);
                    } else {
                        if (fileFilter.accept(new File(filename))) {
                            FileInputStream in = new FileInputStream(filename);
                            processFile(in, filename);
                            in.close();
                        }
                    }
                }
            } catch (IOException e) {
                if (!opt_s)
                    System.err.println(e.toString());

                exitStatus = 2;
            }
        }
    }

    public static void main(String[] args) {
        try {
            args = handleOptions(args);
            args = handleFreeArgs(args);
            sanityCheck();
            init(args);
            grep(args);
        } catch (Exception e) {
//            e.printStackTrace(System.err);
            System.err.println(e.toString());
            exitStatus = 2;
        }
        System.exit(exitStatus);
    }
}
