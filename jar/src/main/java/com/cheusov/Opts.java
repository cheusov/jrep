package com.cheusov;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.filefilter.AndFileFilter;
import org.apache.commons.io.filefilter.FalseFileFilter;
import org.apache.commons.io.filefilter.NotFileFilter;
import org.apache.commons.io.filefilter.OrFileFilter;
import org.apache.commons.io.filefilter.TrueFileFilter;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.apache.commons.lang3.SystemUtils;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

import static com.cheusov.Constants.FOOTER_MESSAGE;
import static com.cheusov.Constants.HELP_REF_MESSAGE;
import static com.cheusov.Constants.OPTION_GROUP_CONTEXT_CONTROL;
import static com.cheusov.Constants.OPTION_GROUP_MISCELLANEOUS;
import static com.cheusov.Constants.OPTION_GROUP_OUTPUT_CONTROL;
import static com.cheusov.Constants.OPTION_GROUP_REGEXP_SELECTION_AND_INTERPRETATION;
import static com.cheusov.Constants.USAGE_MESSAGE;
import static com.cheusov.Constants.HEADER_MESSAGE;

/**
 * Created by Aleksey Cheusov on 4/28/17.
 */
class Opts {
    public static String encoding = System.getProperty("file.encoding");

    public static boolean inverseMatch = false;
    public static boolean outputFilename = false;
    public static boolean opt_o = false;
    public static boolean wholeContent = false;
    public static boolean opt_L = false;
    public static boolean opt_i = false;
    public static boolean opt_h = false;
    public static boolean opt_H = false;
    public static boolean opt_F = false;
    public static boolean opt_c = false;
    public static boolean opt_n = false;
    public static boolean opt_x = false;
    public static boolean opt_q = false;
    public static boolean opt_s = false;
    public static boolean opt_w = false;
    public static boolean opt_line_buffered = false;
    public static int opt_m = 2000000000;
    public static boolean prefixWithFilename = false;
    public static int opt_B = 0;
    public static int opt_A = 0;
    public static String opt_O = null;
    public static JrepPattern.RE_ENGINE_TYPE opt_re_engine = JrepPattern.RE_ENGINE_TYPE.JAVA;

    public static Directories opt_directories = Directories.READ;

    public static String label = "(standard input)";
    public static OrFileFilter orExcludeFileFilter = new OrFileFilter();
    public static OrFileFilter orIncludeFileFilter = new OrFileFilter();
    public static AndFileFilter fileFilter = new AndFileFilter();
    private static OrFileFilter orExcludeDirFilter = new OrFileFilter();
    public static NotFileFilter orIncludeDirFilter = new NotFileFilter(orExcludeDirFilter);

    public static List<String> regexps = new ArrayList<String>();
    public static ArrayList<JrepPattern> patterns = new ArrayList<JrepPattern>();

    public static String colorEscStart;
    public static String colorEscEnd;

    public static boolean isStdoutTTY = false;

    private static boolean withJNI =
            (System.getenv("JREP_NO_JNI") == null) && !SystemUtils.IS_OS_WINDOWS;

    static {
        if (withJNI)
            System.loadLibrary("jrep_jni");

        isStdoutTTY = isStdoutTTY_Any();

        String colorEscSequence = System.getenv("JREP_COLOR");
        if (colorEscSequence == null)
            colorEscSequence = System.getenv("GREP_COLOR");

        if (colorEscSequence != null) {
            colorEscStart = ("\033[" + colorEscSequence + "m");
            colorEscEnd = "\033[1;0m";
        }

        fileFilter.addFileFilter(orIncludeFileFilter);
        fileFilter.addFileFilter(new NotFileFilter(orExcludeFileFilter));

        orExcludeFileFilter.addFileFilter(FalseFileFilter.FALSE);
    }

    public static String[] init(JrepOptionsGroups options, String[] args) throws ParseException, IOException {
        args = handleOptions(options, args);
        args = handleFreeArgs(args);
        sanityCheck();
        initPatterns(args);
        return args;
    }

    private static String[] handleOptions(JrepOptionsGroups options, String[] args) throws ParseException, IOException {
        if (args.length == 0)
            throw new RuntimeException(USAGE_MESSAGE + "\n" + HELP_REF_MESSAGE);

        CommandLineParser parser = new PosixParser();
        CommandLine cmd = parser.parse(options.getOptions(), args);

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

        optArray = cmd.getOptionValues("exclude-dir");
        if (optArray != null && optArray.length != 0) {
            for (String globPattern : optArray) {
                orExcludeDirFilter.addFileFilter(new WildcardFileFilter(globPattern));
            }
        }
        if (orExcludeDirFilter.getFileFilters().isEmpty())
            orExcludeDirFilter.addFileFilter(FalseFileFilter.FALSE);

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

    private static boolean isStdoutTTY_Any() {
        if (withJNI)
            return Utils.isStdoutTTY();
        else
            return true;
    }

    private static void printHelp(JrepOptionsGroups groups) {
        JrepHelpFormatter formatter = new JrepHelpFormatter();
        formatter.setLeftPadding(2);

        PrintWriter pw = new PrintWriter(System.out);

        final int width = formatter.getWidth();
        final int lpad = formatter.getLeftPadding();
        final int dpad = formatter.getDescPadding();
//        formatter.printHelp(USAGE_MESSAGE, options);
        formatter.printWrapped(pw, width, Constants.USAGE_MESSAGE);
        formatter.printWrapped(pw, width, HEADER_MESSAGE);
        formatter.printWrapped(pw, width, "");

        formatter.printWrapped(pw, width, OPTION_GROUP_REGEXP_SELECTION_AND_INTERPRETATION);
        formatter.printHelp(pw, width, " ", null, groups.optionGroups[0], lpad, dpad, null);

        formatter.printWrapped(pw, width, OPTION_GROUP_MISCELLANEOUS);
        formatter.printHelp(pw, width, " ", null, groups.optionGroups[1], lpad, dpad, null);

        formatter.printWrapped(pw, width, OPTION_GROUP_OUTPUT_CONTROL);
        formatter.printHelp(pw, width, " ", null, groups.optionGroups[2], lpad, dpad, null);

        formatter.printWrapped(pw, width, OPTION_GROUP_CONTEXT_CONTROL);
        formatter.printHelp(pw, width, " ", null, groups.optionGroups[3], lpad, dpad, null);

        formatter.printWrapped(pw, formatter.getWidth(), FOOTER_MESSAGE);

        pw.flush();
//        formatter.printHelp(USAGE_MESSAGE, HEADER_MESSAGE, options, FOOTER_MESSAGE, false);
    }

    private static String[] handleFreeArgs(String[] args) {
        if (!regexps.isEmpty())
            return args;

        if (args.length > 0)
            regexps.add(args[0]);
        else
            throw new RuntimeException(USAGE_MESSAGE + "\n" + HELP_REF_MESSAGE);

        return Arrays.copyOfRange(args, 1, args.length);
    }

    private static void sanityCheck() {
        if (regexps.isEmpty()) {
            System.err.println("pattern should be specified");
            System.exit(2);
        }
    }

    private static void initPatterns(String[] args) {
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
}
