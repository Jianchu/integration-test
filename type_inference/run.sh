#!/bin/bash

ROOT=$TRAVIS_BUILD_DIR/type_inference
export JSR308=$ROOT
CORPUS_DIR=../../corpus
SCRIPT=$(readlink -f $0)
MYDIRPATH=`dirname $SCRIPT`
DLJC=$MYDIRPATH/do-like-javac

if [ -d "generic-type-inference-solver" ]; then
  (cd generic-type-inference-solver && git pull)
else
  git clone https://github.com/Jianchu/generic-type-inference-solver.git
fi

if [ -d "do-like-javac" ]; then
  (cd do-like-javac && git pull && git checkout checker)
else
  git clone https://github.com/SRI-CSL/do-like-javac.git
  (cd do-like-javac && git checkout checker)
fi

cd generic-type-inference-solver
export TRAVIS_BUILD_DIR=`pwd`
./.travis-build-without-test.sh
echo "test path"
echo "$JSR308"
echo "begin"
java -classpath /home/travis/build/Jianchu/integration-test/corpus/Sort01/classes:/home/travis/build/Jianchu/integration-test/type_inference/checker-framework-inference/dist/checker.jar:/home/travis/build/Jianchu/integration-test/type_inference/checker-framework-inference/dist/plume.jar:/home/travis/build/Jianchu/integration-test/type_inference/checker-framework-inference/dist/checker-framework-inference.jar checkers.inference.InferenceLauncher --solverArgs backEndType=maxsatbackend.MaxSat --checker ontology.OntologyChecker --solver constraintsolver.ConstraintSolver --mode ROUNDTRIP --hacks=true --targetclasspath /home/travis/build/Jianchu/integration-test/corpus/Sort01/classes -afud ../../corpus/annotated /home/travis/build/Jianchu/integration-test/corpus/Sort01/src/Sort01.java
echo "end"
ls $JSR308
rm -rf $CORPUS_DIR/annotated/
#infer all examples in corpus
for f in $CORPUS_DIR/*
do
  if [ -d "$f" ]; then
    cd $f
    ant clean
    echo "Inferring ${PWD##*/}:"
    python $DLJC/dljc -t inference --solverArgs="backEndType=maxsatbackend.MaxSat" --checker ontology.OntologyChecker --solver constraintsolver.ConstraintSolver -o logs -m ROUNDTRIP -afud $CORPUS_DIR/annotated -- ant
  fi
done

# Sort03 causes checker framework inference crushing,
# the problem has been filed as Issue #24 in checker framework inference.
cd ..