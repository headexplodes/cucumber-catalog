package cucumber.examples.java.calculator;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@CucumberOptions(format = "json:target/cucumber-report.json", dotcucumber = ".cucumber")
public class RunCukesTest {
}
