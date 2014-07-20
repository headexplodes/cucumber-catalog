Cucumber Catalog Generator
==========================

A really simple Java 7 annotation processor to scan for Cucumber-JVM step def annotations (`@Given`, `@When`, `@Then`, `@And` and `@But`) and produce documentation. 

Documentation contains:

 * All step def class names grouped by Java package
 * List of each step and it's regular expression
 * JavaDoc comment (if any) and parsed for Markdown (not HTML)
 * Java source location and snippet the Java step code

Running:

    $ mvn install dependency:copy-dependencies
    $ javac -cp "target/classes:target/dependency/*" -proc:only [sources]

On Linux, to scan for sources:

    $ find path/to/stepdefs -name "*.java" -print | xargs javac -cp "target/classes:target/dependency/*" -proc:only

Other notes:

 * Specify `-Dcatalog.output.file=...` to override default filenames
 * Copy `src/test/resources/cucmber_logo.png` to output location (manual)
 
Links:
 
 * [Cucumber-JVM](https://github.com/cucumber/cucumber-jvm)
 * [Markdown Syntax](http://daringfireball.net/projects/markdown/syntax) 
 
License:

 * Distributed under an MIT license (see LICENSE file)
 * Portions (_Cucumber_ name and logo) Copyright (c) 2008-2013 Aslak Hellesøy and The Cucumber Organisation 

