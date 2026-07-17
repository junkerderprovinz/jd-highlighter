package io.github.junkerderprovinz;

import java.io.File;
import java.lang.instrument.Instrumentation;

/** Registers a FlatLaf custom-defaults source so JD Highlighter's control theme loads.
 *  premain arg = absolute path to the defaults directory holding FlatDarkLaf.properties. */
public final class HighlighterThemeAgent {
    public static void premain(String arg, Instrumentation inst) {
        try {
            File dir = (arg != null && !arg.isEmpty())
                ? new File(arg)
                : new File(System.getProperty("user.home"), ".jd-highlighter/flatlaf-defaults");
            if (!dir.isDirectory()) { System.out.println("[jd-highlighter] defaults dir missing: " + dir); return; }
            // FlatLaf is on JD's classpath by the time the UI starts; retry briefly at premain.
            new Thread(() -> register(dir), "jd-highlighter-register").start();
        } catch (Throwable t) { System.out.println("[jd-highlighter] premain failed: " + t); }
    }
    private static void register(File dir) {
        for (int i = 0; i < 60; i++) {
            try {
                Class<?> flatLaf = Class.forName("com.formdev.flatlaf.FlatLaf");
                flatLaf.getMethod("registerCustomDefaultsSource", File.class).invoke(null, dir);
                System.out.println("[jd-highlighter] registered custom defaults source " + dir);
                return;
            } catch (ClassNotFoundException notYet) {
                try { Thread.sleep(500); } catch (InterruptedException ie) { return; }
            } catch (Throwable t) { System.out.println("[jd-highlighter] register failed: " + t); return; }
        }
        System.out.println("[jd-highlighter] FlatLaf never appeared; giving up");
    }
}
