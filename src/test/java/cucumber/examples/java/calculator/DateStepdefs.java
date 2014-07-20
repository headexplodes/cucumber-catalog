package cucumber.examples.java.calculator;

import static org.junit.Assert.assertEquals;

import java.util.Date;

import cucumber.api.Format;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.catalog.Catalog;

public class DateStepdefs {
    private String result;
    private DateCalculator calculator;

    @Catalog("Sets the current day for future steps")
    @Given("^today is (.+)$")
    public void today_is(@Format("yyyy-MM-dd") Date date) {
        calculator = new DateCalculator(date);
    }

    /**
     * We don't need to use `@Format` here, since the date string in the step
     * conforms to `SimpleDateFormat.SHORT`. Cucumber has built-in support for `SimpleDateFormat.SHORT`,
     * `SimpleDateFormat.MEDIUM`, `SimpleDateFormat.LONG` and `SimpleDateFormat.FULL`.
     * 
     *     Scenario: Determine past date
     *     Given today is 2011-01-20
     *     When I ask if Jan 19, 2011 is in the past
     *     Then the result should be yes
     */
    @When("^I ask if (.+) is in the past$")
    public void I_ask_if_date_is_in_the_past(Date date) {
        result = calculator.isDateInThePast(date);
    }

    @Then("^the result should be (.+)$")
    public void the_result_should_be(String expectedResult) {
        assertEquals(expectedResult, result);
    }
}
