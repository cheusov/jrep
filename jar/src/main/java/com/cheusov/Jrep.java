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

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.filefilter.*;
import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.tuple.Pair;

import java.io.*;
import java.util.*;
import java.util.regex.Pattern;

/**
 * Created by Aleksey Cheusov on 4/24/16.
 */
public class Jrep {

    private static final JrepOptionsGroups optionsGroups = new JrepOptionsGroups();
    private static int exitStatus = 1;
    private static final String[] stdinFilenames = {"-"};
    private static final Pattern patternSpaces = Pattern.compile("\\p{IsWhiteSpace}+");
    private static final Pattern patternSpacesBeg = Pattern.compile("^\\p{IsWhiteSpace}+");
    private static final Pattern patternSpacesEnd = Pattern.compile("\\p{IsWhiteSpace}+$");

    private static void println(String line) {
        if (!Opts.opt_q) {
            System.out.println(line);
            if (Opts.opt_line_buffered)
                System.out.flush();
        }
    }

    private static void printlnWithPrefix(String filename, String line, int lineNumber, char separator) {
        String prefix1 = "";
        if (Opts.prefixWithFilename)
            prefix1 = filename + separator;
        String prefix = prefix1;
        if (Opts.opt_n)
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
                sb.append(Opts.colorEscStart);
                sb.append(line.substring(start, end));
                sb.append(Opts.colorEscEnd);
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
            } else {
                sbLetters.append(c);
            }
        }

        return ret;
    }

    private static String getGroup(JrepMatchResult match, int groupNum) {
        String value = match.group(groupNum);
        if (value == null)
            return "";

        return value;
    }

    private static String getOutputString(String line, JrepMatchResult match, String filename) {
        if (Opts.opt_O == null)
            return line.substring(match.start(), match.end());

        StringBuilder b = new StringBuilder();
        int len = Opts.opt_O.length();
        for (int i = 0; i < len; ++i) {
            char c = Opts.opt_O.charAt(i);
            if (c != '$') {
                b.append(c);
            } else {
                if (i + 1 == len)
                    throw new IllegalArgumentException("Unexpected `$` in -O argument: `" + Opts.opt_O + "`");

                char nc = Opts.opt_O.charAt(i + 1);

                String value = "";
                CharSequence l = "";
                if (nc == '{') {
                    StringBuilder[] ld;
                    i += 1;
                    ld = extractCurlyBraces(Opts.opt_O, i + 1);
                    l = ld[0];
                    StringBuilder d = ld[1];
                    i += d.length() + l.length();

                    if (d.length() > 0) {
                        nc = '\0';
                        int groupNum = Integer.valueOf(d.toString());
                        value = getGroup(match, groupNum);
                    }

                    if (d.length() == 0 && l.length() > 0) {
                        nc = l.charAt(0);
                        l = l.subSequence(1, l.length());
                    }
                }

                ++i;

//                System.err.println("zzz: " + l);

                switch (nc) {
                    case '\0':
                        break;
                    case 'f':
                        value = filename;
                        break;
                    case '<':
                        value = Opts.colorEscStart;
                        break;
                    case '>':
                        value = Opts.colorEscEnd;
                        break;
                    case '$':
                        value = "$";
                        break;
                    case '0':case '1':case '2': case '3':case '4':case '5':case '6':case '7':case '8':case '9':
                        value = getGroup(match, nc - '0');
                        break;
                    default:
                        throw new IllegalArgumentException("Illegal `$" + nc + "` in -O argument: `" + Opts.opt_O + "`");
                }

                for (int j = 0; j < l.length(); ++j) {
                    char lc = l.charAt(j);
                    switch (lc) {
                        case 'n':
                            value = value.replaceAll("\\\\", "\\\\\\\\").replaceAll("\n", "\\\\n");
                            break;
                        case 'N':
                            value = value.replaceAll("\n", " ");
                            break;
                        case 's':
                            value = patternSpaces.matcher(value).replaceAll(" ");
                            break;
                        case 't':
                            value = patternSpacesBeg.matcher(value).replaceFirst("");
                            value = patternSpacesEnd.matcher(value).replaceFirst("");
                            break;
                        case 'b':
                            value = new File(value).getName();
                            break;
                        case 'c':
                            value = StringEscapeUtils.escapeCsv(value);
                            break;
                        case 'C':
                            value = "\"" + value.replaceAll("\"", "\"\"") + "\"";
                            break;
                        default:
                            throw new IllegalArgumentException("Unexpected modifier `" + lc + "' in -O argument");
                    }
                }
                b.append(value);
            }
        }

        return b.toString();
    }

    private static void processFile(InputStream in, String filename) throws IOException {
        Iterator<String> it;
        if (Opts.wholeContent) {
            String fileContent = IOUtils.toString(in, Opts.encoding);
            it = Arrays.asList(fileContent).iterator();
        } else {
            it = IOUtils.lineIterator(in, Opts.encoding);
        }

        int matchCount = 0;
        List<Pair<Integer, Integer>> startend = null;
        int lineNumber = 0;
        int lastMatchedLineNumber = 0;
        Map<Integer, String> lines = new HashMap<Integer, String>();
        while (it.hasNext()) {
            ++lineNumber;

            String line = (String) it.next();
            if (Opts.opt_B > 0) {
                lines.put(lineNumber, line);
                lines.remove(lineNumber - Opts.opt_B - 1);
            }

            boolean matched = false;
            boolean nextFile = false;

            if (!Opts.inverseMatch && !Opts.outputFilename && !Opts.opt_o && !Opts.opt_L && !Opts.opt_c)
                startend = new ArrayList<Pair<Integer, Integer>>();

            String lineToPrint = null;
            for (JrepPattern pattern : Opts.patterns) {
                int pos = 0;
                JrepMatchResult m = pattern.matcher(line);
                int lineLength = line.length();

//                boolean nextLine = false;
                while (pos < lineLength && m.find(pos)) {
                    matched = true;

                    if (Opts.outputFilename || Opts.opt_c || Opts.opt_L || Opts.inverseMatch) {
                        break;
                    } else if (Opts.opt_o) {
                        printlnWithPrefix(filename, getOutputString(line, m, filename), lineNumber, ':');
                    } else if (Opts.colorEscStart != null) {
                        startend.add(Pair.of(m.start(), m.end()));
                    }

                    pos = m.end();
                    if (m.start() == m.end())
                        ++pos;
                }
            }

            matched ^= Opts.inverseMatch;

            if (matched) {
                if (exitStatus == 1)
                    exitStatus = 0;

                if (!Opts.outputFilename && !Opts.opt_o && !Opts.opt_L && !Opts.opt_c) {
                    if (Opts.colorEscStart == null || startend == null)
                        lineToPrint = line;
                    else
                        lineToPrint = getLineToPrint(line, startend);
                }

                if (Opts.outputFilename) {
                    println(filename);
                    nextFile = true;
                }
            }

            if (lineToPrint != null) {
                for (int prevLineNumber = lineNumber - Opts.opt_B; prevLineNumber < lineNumber; ++prevLineNumber) {
                    String prevLine = lines.get(prevLineNumber);
                    if (prevLine != null) {
                        lines.remove(prevLineNumber);
                        printlnWithPrefix(filename, prevLine, prevLineNumber, '-');
                    }
                }

                lastMatchedLineNumber = lineNumber;

                lines.remove(lineNumber);
                printlnWithPrefix(filename, lineToPrint, lineNumber, ':');
            } else if (lastMatchedLineNumber > 0 && lastMatchedLineNumber + Opts.opt_A >= lineNumber) {
                lines.remove(lineNumber);
                printlnWithPrefix(filename, line, lineNumber, '-');
            }

            if (matched) {
                ++matchCount;
                if (matchCount == Opts.opt_m)
                    nextFile = true;
            }

            if (nextFile)
                break;
        }

        if (Opts.opt_L && matchCount == 0)
            println(filename);

        if (Opts.opt_c)
            printlnWithPrefix(filename, "" + matchCount, lineNumber, ':');
    }

    private static void grep(String[] args) throws Exception {
        if (args.length == 0)
            args = stdinFilenames;

        for (String fileOrDir : args) {
            try {
                Iterator fileIterator;
                File file = new File(fileOrDir);
                boolean isDir = false;
                if (Opts.opt_directories != Directories.READ) {
                    isDir = file.isDirectory();
                }

                if (isDir && Opts.opt_directories == Directories.SKIP)
                    continue;

                if (isDir && Opts.opt_directories == Directories.RECURSE) {
                    if (!Opts.orIncludeDirFilter.accept(file))
                        continue;
                    fileIterator = FileUtils.iterateFiles(file, Opts.fileFilter, Opts.orIncludeDirFilter);
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
                        processFile(System.in, Opts.label);
                    } else {
                        if (Opts.fileFilter.accept(new File(filename))) {
                            FileInputStream in = new FileInputStream(filename);
                            processFile(in, filename);
                            in.close();
                        }
                    }
                }
            } catch (IOException e) {
                if (!Opts.opt_s) {
//                    e.printStackTrace(System.err);
                    System.err.println(e.toString());
                }

                exitStatus = 2;
            }
        }
    }

    public static void main(String[] args) {
        try {
            args = Opts.init(optionsGroups, args);
            grep(args);
        } catch (RuntimeException e) {
//            e.printStackTrace(System.err);
            System.err.println(e.getMessage());
            exitStatus = 2;
        } catch (Exception e) {
//            e.printStackTrace(System.err);
            System.err.println(e.toString());
            exitStatus = 2;
        }
        System.exit(exitStatus);
    }
}
