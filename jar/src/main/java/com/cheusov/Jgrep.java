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
import org.apache.commons.lang3.tuple.Pair;

import java.io.*;
import java.util.*;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Aleksey Cheusov on 4/24/16.
 */
public class Jgrep {
    private static List<String> regexps = new ArrayList<String>();
    private static ArrayList<Pattern> patterns = new ArrayList<Pattern>();
    private static int patternFlags;
    private static int exitStatus = 1;

    private static boolean inverseMatch = false;
    private static boolean outputFilename = false;
    private static boolean opt_o = false;
    private static boolean wholeContent = false;
    private static boolean opt_L = false;
    private static boolean opt_h = false;
    private static boolean opt_H = false;
    private static boolean opt_F = false;
    private static boolean opt_c = false;
    private static boolean opt_n = false;
    private static boolean opt_x = false;
    private static boolean opt_q = false;
    private static boolean opt_r = false;
    private static boolean opt_s = false;
    private static boolean opt_w = false;
    private static boolean opt_line_buffered = false;
    private static int opt_m = 2000000000;
    private static boolean prefixWithFilename = false;
    private static int opt_B = 0;
    private static int opt_A = 0;
    private static String opt_O = null;
    private static String label = "(standard input)";
    private static OrFileFilter orExcludeFileFilter = new OrFileFilter();
    private static OrFileFilter orIncludeFileFilter = new OrFileFilter();
    private static AndFileFilter fileFilter = new AndFileFilter();

    private static String colorEscSequence;
    private static String colorEscStart;
    private static String colorEscEnd;

    static {
        fileFilter.addFileFilter(orIncludeFileFilter);
        fileFilter.addFileFilter(new NotFileFilter(orExcludeFileFilter));

        colorEscSequence = System.getenv("JGREP_COLOR");
        if (colorEscSequence == null)
            colorEscSequence = System.getenv("GREP_COLOR");

        if (colorEscSequence != null) {
            colorEscStart = ("\033[" + colorEscSequence + "m");
            colorEscEnd = "\033[1;0m";
        }
    }

    private static class SingleStringIterator implements Iterator<String> {
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
            if (start + 1 < end) {
                sb.append(colorEscStart);
                sb.append(line.substring(start, end));
                sb.append(colorEscEnd);
            }
            prev = end;
        }

        return (sb.toString() + line.substring(prev));
    }

    private static String getOutputString(String line, MatchResult match){
        if (opt_O == null)
            return line.substring(match.start(), match.end());

        StringBuilder b = new StringBuilder();
        int len = opt_O.length();
        for (int i = 0; i < len; ++i){
            char c = opt_O.charAt(i);
            if (c != '\\') {
                b.append(c);
            } else {
                if (i + 1 == len)
                    throw new IllegalArgumentException("Unexpected `\\` in -O argument: `" + opt_O + "`");
                char nc = opt_O.charAt(i + 1);
                if (nc == '\\')
                    b.append('\\');
                else if (nc >= '0' && nc <= '9')
                    b.append(match.group(nc - '0'));
                else
                    throw new IllegalArgumentException("Illegal `\\" + nc + "` in -O argument: `" + opt_O + "`");

                ++i;
            }
        }

        return b.toString();
    }

    private static void processFile(InputStream in, String filename) throws IOException {
//        LineIterator it = FileUtils.lineIterator(new File(filename), "UTF-8");
        Iterator<String> it;
        if (wholeContent) {
            String fileContent = IOUtils.toString(in, "UTF-8");
            it = new SingleStringIterator(fileContent);
        } else {
            it = IOUtils.lineIterator(in, "UTF-8");
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
            for (Pattern pattern : patterns) {
                int pos = 0;
                Matcher m = pattern.matcher(line);

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

    private static String[] handleOptions(String[] args) throws ParseException, IOException {
        Options options = new Options();
//        options.addOption("t", false, "display current time");
        options.addOption("e", "regexp", true, "Specify a pattern used during the search of the input: an input line is " +
                "selected if it matches any of the specified patterns." +
                "This option is most useful when multiple -e options are used to specify multiple patterns, " +
                "or when a pattern begins with a dash (‘-’).");
        options.addOption("i", "ignore-case", false, "Perform case insensitive matching. By default, " +
                "grep is case sensitive.");
        options.addOption("v", "invert-match", false, "Selected lines are those not matching any of " +
                "the specified patterns.");
        options.addOption("l", "files-with-matches", false, "Only the names of files containing selected lines " +
                "are written to standard output. grep will only search a file until a match has been found, " +
                "making searches potentially less expensive. Pathnames are listed once per file searched. " +
                "If the standard input is searched, the string “(standard input)” is written.");
        options.addOption("o", "only-matching", false, "Print each match, but only the match, not the entire line.");
        options.addOption("L", "files-without-match", false, "Only the names of files not containing selected lines " +
                "are written to standard output. Pathnames are listed once per file searched. " +
                "If the standard input is searched, the string “(standard input)” is written.");
        options.addOption("h", "no-filename", false, "Never print filename headers (i.e. filenames) with output lines.");
        options.addOption("H", "with-filename", false, "Print the file name for each match.");
        options.addOption("E", "extended-regexp", false, "Ignored.");
        options.addOption("G", "basic-regexp", false, "Ignored.");
        options.addOption("P", "perl-regexp", false, "Ignored.");
        options.addOption("8", false, "Match the whole file content at once.");
        options.addOption("F", "fixed-strings", false, "Interpret pattern as a set of fixed strings.");
        options.addOption("c", "count", false, "Only a count of selected lines is written to standard output.");
        options.addOption("n", "line-number", false, "Each output line is preceded by its relative line number " +
                "in the file, starting at line 1. The line number counter is reset for each file processed. " +
                "This option is ignored if -c, -L, -l, or -q is specified.");
        options.addOption("m", "max-count", true, "Stop after ARG matches.");
        options.addOption("x", "line-regexp", false, "Only input lines selected against an entire fixed string " +
                "or regular expression are considered to be matching lines.");
        options.addOption(null, "help", false, "Display this help text and exit.");
        options.addOption("V", "version", false, "Display version information and exit.");
        options.addOption(null, "line-buffered", false, "Flush output on every line.");
        options.addOption("s", "no-messages", false, "Suppress error messages");
        options.addOption("q", "quiet", false, "Quiet. Nothing shall be written to the standard output," +
                " regardless of matching lines. Exit with zero status if an input line is selected.");
        options.addOption(null, "silent", false, "Same as --quiet.");
        options.addOption(null, "label", true, "Use ARG as the standard input file name prefix.");
        options.addOption("w", "word-regexp", false, "Force PATTERN to match only whole words.");
        options.addOption("f", "file", true, "Obtain PATTERN from FILE.");
        options.addOption("r", "recursive", false, "Recursively search subdirectories listed.");
        options.addOption(null, "marker-start", true, "Marker for the beginning of matched substring.");
        options.addOption(null, "marker-end", true, "Marker for the end of matched substring.");
        options.addOption(null, "include", true, "Search only files that match ARG pattern.");
        options.addOption(null, "exclude", true, "Skip files matching ARG.");
        options.addOption("A", "after-context", true, "Print ARG lines of trailing context.");
        options.addOption("B", "before-context", true, "Print ARG lines of leading context.");
        options.addOption("C", "context", true, "Print ARG lines of output context.");
        options.addOption("O", "output-format", true, "Same as -o but ARG specifies the output format." +
                " \\N means group number N, \\\\ means \\. All other characters are output as is.");

        CommandLineParser parser = new PosixParser();
        CommandLine cmd = parser.parse(options, args);

        if (cmd.hasOption("i"))
            patternFlags = Pattern.CASE_INSENSITIVE;

        inverseMatch = cmd.hasOption("v");
        outputFilename = cmd.hasOption("l");
        opt_O = cmd.getOptionValue("O");
        opt_o = cmd.hasOption("o") || (opt_O != null);
        wholeContent = cmd.hasOption("8");
        opt_L = cmd.hasOption("L");
        opt_h = cmd.hasOption("h");
        opt_H = cmd.hasOption("H");
        opt_F = cmd.hasOption("F");
        opt_c = cmd.hasOption("c");
        opt_n = cmd.hasOption("n");
        opt_x = cmd.hasOption("x");
        opt_r = cmd.hasOption("r");
        opt_s = cmd.hasOption("s");
        opt_q = cmd.hasOption("q") || cmd.hasOption("silent");
        opt_w = cmd.hasOption("w");
        opt_line_buffered = cmd.hasOption("line-buffered");

        String[] opt_e = cmd.getOptionValues("e");
        if (opt_e != null && opt_e.length != 0) {
            for (String regexp : opt_e)
                regexps.add(regexp);
        }

        {
            String[] optinclude = cmd.getOptionValues("include");
            if (optinclude != null && optinclude.length != 0) {
                for (String globPattern : optinclude)
                    orIncludeFileFilter.addFileFilter(new WildcardFileFilter(globPattern));
            } else {
                orIncludeFileFilter.addFileFilter(TrueFileFilter.TRUE);
            }
        }

        {
            String[] optexclude = cmd.getOptionValues("exclude");
            if (optexclude != null && optexclude.length != 0) {
                for (String globPattern : optexclude) {
                    orExcludeFileFilter.addFileFilter(new WildcardFileFilter(globPattern));
                }
            } else {
                orExcludeFileFilter.addFileFilter(FalseFileFilter.FALSE);
            }
        }

        String optf = cmd.getOptionValue("f");
        if (optf != null) {
            Iterator<String> it = IOUtils.lineIterator(new FileInputStream(optf), "UTF-8");
            while (it.hasNext()) {
                regexps.add(it.next());
            }
        }

        String optm = cmd.getOptionValue("m");
        if (optm != null)
            opt_m = Integer.valueOf(optm);

        String optLabel = cmd.getOptionValue("label");
        if (optLabel != null)
            label = optLabel;

        String optmarkerstart = cmd.getOptionValue("marker-start");
        if (optmarkerstart != null)
            colorEscStart = optmarkerstart;
        String optmarkerend = cmd.getOptionValue("marker-end");
        if (optmarkerend != null)
            colorEscEnd = optmarkerend;

        String optA = cmd.getOptionValue("A");
        if (optA != null)
            opt_A = Integer.valueOf(optA);

        String optB = cmd.getOptionValue("B");
        if (optB != null)
            opt_B = Integer.valueOf(optB);

        String optC = cmd.getOptionValue("C");
        if (optC != null)
            opt_A = opt_B = Integer.valueOf(optC);

        if (cmd.hasOption("help")) {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp("jgrep", options);
            System.exit(0);
        }

        if (cmd.hasOption("V")) {
            System.out.println("jgrep-" + System.getenv("JGREP_VERSION"));
            System.exit(0);
        }

        return cmd.getArgs();
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
        } else if (opt_x) {
            for (int i = 0; i < regexps.size(); ++i)
                regexps.set(i, "(?m:^(?:" + regexps.get(i) + ")$)");
        } else if (opt_w) {
            for (int i = 0; i < regexps.size(); ++i)
                regexps.set(i, "\\b(?:" + regexps.get(i) + ")\\b");
        }

        for (int i = 0; i < regexps.size(); ++i)
            patterns.add(Pattern.compile(regexps.get(i), patternFlags));

        prefixWithFilename = (opt_H || opt_r || (args.length > 1 && !opt_h));
    }

    private static final String[] stdinFilenames = {"-"};

    private static void grep(String[] args) throws Exception {
        if (args.length == 0)
            args = stdinFilenames;

        for (String fileOrDir : args) {
            try {
                Iterator fileIterator;
                if (opt_r) {
                    fileIterator = FileUtils.iterateFiles(new File(fileOrDir), fileFilter, DirectoryFileFilter.DIRECTORY);
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
                        FileInputStream in = new FileInputStream(filename);
                        processFile(in, filename);
                        in.close();
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
