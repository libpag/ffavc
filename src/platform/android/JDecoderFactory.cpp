#include <jni.h>
#include "ffavc.h"

extern "C" {

JNIEXPORT jlong Java_org_ffavc_DecoderFactory_GetHandle(JNIEnv*, jclass) {
  return reinterpret_cast<jlong>(ffavc::DecoderFactory::GetHandle());
}

}

