# test_battery

## Short Motivation
Profiling a program involves running a lot of very long, very complicated ascii strings on the command line. 
This system makes it extremely easy and can be adapted to a wide range of profiling workflows.

## Long Motivation
Running profiling on a compiled executable typically involves analyzing its output across multiple runs.
These runs represent a wide range of input parameters and runtime environments. 
Typically, at the conclusion of each run, you will have some kind of informative output from a profiling tool.
However, getting that usable profiling output from a single run may require you to run a multi-stage pipeline.
Each stage entails producing an output file and then inputting it into another tool.
In practice, this translates to extremely long, complicated command line commands.

## This profiling system
The script "executable_test.sh" builds complicated command line strings and runs them based on a config file.
The config file conforms to a simple specification.

## Level 0 specification overview
The specification does this:

[declare command line string]
[run it]
[declare another command line string based off of the previous one]
[run it] 
.
.
.

## Level 1 specification overview

The script builds a command line string according to sections like this:

[prepend_actions] [executable] [unordered command line args] [append_actions] ; [post_actions]

Real example:

