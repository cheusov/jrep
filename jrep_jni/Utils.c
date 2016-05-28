#include "Utils.h"
#include <unistd.h>

JNIEXPORT jboolean JNICALL Java_com_cheusov_Utils_isStdoutTTY
  (JNIEnv *env, jclass cls)
{
    return isatty(STDOUT_FILENO) ? JNI_TRUE: JNI_FALSE;
}
