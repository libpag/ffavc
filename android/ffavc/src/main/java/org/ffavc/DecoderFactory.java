package org.ffavc;

public class DecoderFactory {
    static {
        System.loadLibrary("ffavc");
    }

    public static native long GetHandle();
}
