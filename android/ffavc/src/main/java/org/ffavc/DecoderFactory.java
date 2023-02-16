package org.ffavc;

import org.ffavc.extra.tools.LibraryLoadUtils;

public class DecoderFactory {
    static {
        LibraryLoadUtils.loadLibrary("ffavc");
    }

    public static native long GetHandle();
}
