classpath=.:../src/java:velocity-1.4.jar:velocity-dep-1.4.jar
java -classpath $classpath BenchmarkTest $* -cache true  KwartzBenchmark
java -classpath $classpath BenchmarkTest $* -cache false KwartzBenchmark
java -classpath $classpath BenchmarkTest $* -cache true  VelocityBenchmark
java -classpath $classpath BenchmarkTest $* -cache false VelocityBenchmark
