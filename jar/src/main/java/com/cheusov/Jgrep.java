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
import org.apache.commons.lang3.tuple.Pair;

import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

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
    private static boolean outputMatched = false;
    private static boolean wholeContent = false;
    private static boolean opt_L = false;
    private static boolean opt_h = false;
    private static boolean opt_F = false;
    private static boolean opt_c = false;
    private static boolean opt_n = false;
    private static boolean opt_x = false;
    private static boolean opt_line_buffered = false;
    private static int opt_m = 2000000000;
    private static boolean prefixWithFilename = false;

    private static String colorEscSequence;

    static {
        colorEscSequence = System.getenv("JGREP_COLOR");
        if (colorEscSequence == null)
            colorEscSequence = System.getenv("GREP_COLOR");
    }

    private static class SingleStringIterator implements Iterator<String> {
        String str;

        public SingleStringIterator (String str){
            this.str = str;
        }

        public boolean hasNext(){
            return str != null;
        }

        public String next(){
            String ret = str;
            str = null;
            return ret;
        }

        public void remove() {
            str = null;
        }
    }

    private static void println(String line){
        System.out.println(line);
        if (opt_line_buffered)
            System.out.flush();
    }

    private static void processFile(InputStream in, String filename) throws IOException {
//        LineIterator it = FileUtils.lineIterator(new File(filename), "UTF-8");
        Iterator<String> it;
        if (wholeContent) {
            String fileContent = FileUtils.readFileToString(new File(filename));
            it = new SingleStringIterator(fileContent);
        }else {
            it = IOUtils.lineIterator(in, "UTF-8");
        }

        String prefix1 = "";
        if (prefixWithFilename)
            prefix1 = filename + ":";

        int matchCount = 0;
        List<Pair<Integer, Integer>> startend = null;
        int lineNumber = 0;
        while (it.hasNext()){
            ++lineNumber;
            String prefix = prefix1;
            if (opt_n)
                prefix = prefix + lineNumber + ":";

            String line = (String)it.next();
            boolean matched = false;
            boolean nextFile = false;

            if (!inverseMatch && !outputFilename && !outputMatched && !opt_L && !opt_c)
                startend = new ArrayList<Pair<Integer, Integer>>();

            int pos = 0;
            for (Pattern pattern : patterns) {
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
                        println(prefix + line);
                        break;
                    } else if (outputMatched) {
                        println(prefix + line.substring(m.start(), m.end()));
                    } else if (colorEscSequence == null) {
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

            if (matched){
                ++matchCount;
                if (matchCount == opt_m)
                    nextFile = true;
            }

            if (matched){
                if (! inverseMatch && ! outputFilename && ! outputMatched && ! opt_L && ! opt_c) {
                    StringBuilder sb = new StringBuilder();
                    int prev = 0;
                    for (Pair<Integer, Integer> p : startend){
                        int start = p.getLeft();
                        int end   = p.getRight();
                        sb.append(line.substring(prev, start));
                        sb.append("\033[" + colorEscSequence + "m");
                        sb.append(line.substring(start, end));
                        sb.append("\033[1;0m");
                        prev = end;
                    }
                    println(prefix + sb.toString() + line.substring(prev));
                }
            }

            if (nextFile)
                break;
        }

        if (opt_L && matchCount == 0)
            println(filename);

        if (opt_c)
            println(prefix1 + matchCount);
    }

    private static String[] handleOptions(String[] args) throws org.apache.commons.cli.ParseException {
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
        options.addOption("E", "extended-regexp", false, "Ignored.");
        options.addOption("G", "basic-regexp", false, "Ignored.");
        options.addOption("P", "perl-regexp", false, "Ignored.");
        options.addOption("8", false, "Match the whole file content at once.");
        options.addOption("F", "fixed-strings", false, "Interpret pattern as a set of fixed strings.");
        options.addOption("c", "count", false, "Only a count of selected lines is written to standard output.");
        options.addOption("n", "line-number", false, "Each output line is preceded by its relative line number " +
                "in the file, starting at line 1. The line number counter is reset for each file processed. " +
                "This option is ignored if -c, -L, -l, or -q is specified.");
        options.addOption("m", "max-count", true,  "Stop after ARG matches.");
        options.addOption("x", "line-regexp", false, "Only input lines selected against an entire fixed string " +
                "or regular expression are considered to be matching lines.");
        options.addOption(null, "help", false, "Display this help text and exit.");
        options.addOption("V", "version", false, "Display version information and exit.");
        options.addOption(null, "line-buffered", false, "Display version information and exit.");

        CommandLineParser parser = new PosixParser();
        CommandLine cmd = parser.parse (options, args);

        if(cmd.hasOption("i"))
            patternFlags = Pattern.CASE_INSENSITIVE;

        inverseMatch = cmd.hasOption("v");
        outputFilename = cmd.hasOption("l");
        outputMatched = cmd.hasOption("o");
        wholeContent = cmd.hasOption("8");
        opt_L = cmd.hasOption("L");
        opt_h = cmd.hasOption("h");
        opt_F = cmd.hasOption("F");
        opt_c = cmd.hasOption("c");
        opt_n = cmd.hasOption("n");
        opt_x = cmd.hasOption("x");
        opt_line_buffered = cmd.hasOption("line-buffered");

        String[] opt_e = cmd.getOptionValues("e");
        if (opt_e != null && opt_e.length != 0) {
            for (String regexp : opt_e)
                regexps.add(regexp);
        }

        String optM = cmd.getOptionValue("m");
        if (optM != null)
            opt_m = Integer.valueOf(optM);

        if (cmd.hasOption("help")){
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp( "jgrep", options );
            System.exit(0);
        }

        if (cmd.hasOption("V")){
            System.out.println("jgrep-" + System.getenv("JGREP_VERSION"));
            System.exit(0);
        }

        return cmd.getArgs();
    }

    private static void sanityCheck()
    {
        if (regexps.isEmpty()){
            System.err.println("pattern should be specified");
            System.exit(2);
        }
    }

    private static String[] handleFreeArgs(String[] args) {
        if (! regexps.isEmpty())
            return args;

        if (args.length > 0)
            regexps.add(args[0]);

        return Arrays.copyOfRange(args, 1, args.length);
    }

    private static void init(String[] args){
        if (opt_F){
            for (int i=0; i < regexps.size(); ++i)
                regexps.set(i, "\\Q" + regexps.get(i) + "\\E");
        }else if (opt_x){
            for (int i=0; i < regexps.size(); ++i)
                regexps.set(i, "(?m:^(?:" + regexps.get(i) + ")$)");
        }

        for (int i = 0; i < regexps.size(); ++i)
            patterns.add(Pattern.compile(regexps.get(i), patternFlags));

        prefixWithFilename = args.length > 1 && ! opt_h;
    }

    private static void grep(String[] args) throws Exception {
        if (args.length == 0) {
            processFile(System.in, "(standard input)");
        }else{
            for (String filename : args){
                try {
                    FileInputStream in = new FileInputStream(filename);
                    processFile(in, filename);
                    in.close();
                }
                catch (IOException e){
                    System.err.println(e.toString());
                    exitStatus = 2;
                }
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
        }
        catch (Exception e) {
//            e.printStackTrace(System.err);
            System.err.println(e.toString());
            exitStatus = 2;
        }
        System.exit(exitStatus);
    }
}
