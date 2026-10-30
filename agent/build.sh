#!/bin/sh
# Builds agent/jd-highlighter-agent.jar. JDownloader runs on Java 21, so the classes
# target 21; a newer class version crash-loops the GUI. ASM is checked against its
# SHA-256 and unpacked into the jar, which keeps the -javaagent self-contained.
set -eu
cd "$(dirname "$0")"

ASM_URL=https://repo1.maven.org/maven2/org/ow2/asm/asm/9.7.1/asm-9.7.1.jar
ASM_SHA=8cadd43ac5eb6d09de05faecca38b917a040bb9139c7edeb4cc81c740b713281

rm -rf build
mkdir -p build/classes
curl -fsSL "$ASM_URL" -o build/asm.jar
echo "$ASM_SHA  build/asm.jar" | sha256sum -c -

javac --release 21 -nowarn -cp build/asm.jar -d build/classes \
  src/io/github/junkerderprovinz/DialogConfirmAgent.java
javap -v -classpath build/classes io.github.junkerderprovinz.DialogConfirmAgent | grep -q 'major version: 65'

(cd build/classes && jar xf ../asm.jar org/objectweb/asm)
jar cfm jd-highlighter-agent.jar manifest.mf -C build/classes .
rm -rf build
echo "Built agent/jd-highlighter-agent.jar (Java 21 classes)"
