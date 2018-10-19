LIBRARY_VERSION=1.5-ea
LIB_PROFILER=libasyncProfiler.so
JATTACH=jattach
BINARIES=build/$(LIB_PROFILER) build/$(JATTACH)
PROFILER=async-profiler
PROFILER_JAR=$(PROFILER).jar
CC=gcc
CFLAGS=-O2
CPP=g++
CPPFLAGS=-O2
INCLUDES=-I$(JAVA_HOME)/include
LIBS=-ldl -lpthread
JAVAC=$(JAVA_HOME)/bin/javac
JAR=$(JAVA_HOME)/bin/jar

#set to you own group
MVN_GROUP_ID=org.jetbrains.intellij.deps
MVN_ARTIFACT_ID=$(PROFILER)

ifeq ($(JAVA_HOME),)
  export JAVA_HOME:=$(shell java -cp . JavaHome)
endif

OS:=$(shell uname -s)
ifeq ($(OS), Darwin)
  CPPFLAGS += -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE
  INCLUDES += -I$(JAVA_HOME)/include/darwin
  RELEASE_TAG:=$(LIBRARY_VERSION)-macos-x64
else
  LIBS += -lrt
  INCLUDES += -I$(JAVA_HOME)/include/linux
  RELEASE_TAG:=$(LIBRARY_VERSION)-linux-x64
endif


.PHONY: all binaries release test clean

all: build/$(PROFILER_JAR)

release: async-profiler-$(RELEASE_TAG).tar.gz

async-profiler-$(RELEASE_TAG).tar.gz: $(BINARIES) build/$(PROFILER_JAR) profiler.sh LICENSE *.md
	tar cvzf $@ $^

binaries: $(BINARIES)

build/$(LIB_PROFILER): src/*.cpp src/*.h
	mkdir -p build
	$(CPP) $(CPPFLAGS) -DPROFILER_VERSION=\"$(LIBRARY_VERSION)\" $(INCLUDES) -fPIC -shared -o $@ src/*.cpp $(LIBS)

build/$(JATTACH): src/jattach/jattach.c
	mkdir -p build
	$(CC) $(CFLAGS) -DJATTACH_VERSION=\"$(LIBRARY_VERSION)\" -o $@ $^

build/$(PROFILER_JAR): src/java/one/profiler/*.java
	mkdir -p build/classes
	$(JAVAC) -source 6 -target 6 -d build/classes $^
	$(JAR) cvf $@ -C build/classes .
	rm -rf build/classes

bintray/$(PROFILER)-$(LIBRARY_VERSION).jar: src/java/one/profiler/*.java
	mkdir -p bintray
	$(JAVAC) -source 6 -target 6 -d publish $^
	sh write_pom.sh $(MVN_GROUP_ID) $(MVN_ARTIFACT_ID) $(LIBRARY_VERSION) > publish/pom.xml
	$(JAR) cvf $@ publish

bintray: bintray/$(PROFILER)-$(LIBRARY_VERSION).jar
	mv publish/pom.xml bintray/$(PROFILER)-$(LIBRARY_VERSION).pom

test: all
	test/smoke-test.sh
	test/alloc-smoke-test.sh
	echo "All tests passed"

clean:
	rm -rf build
	rm -rf publish
	rm -rf bintray
