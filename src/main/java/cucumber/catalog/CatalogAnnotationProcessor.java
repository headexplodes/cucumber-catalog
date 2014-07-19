package cucumber.catalog;

import java.io.File;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.lang.model.util.Elements;
import javax.tools.Diagnostic;
import javax.xml.bind.JAXB;

import com.sun.tools.javac.model.JavacElements;

import cucumber.api.java.en.And;
import cucumber.api.java.en.But;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.catalog.xml.CatalogModel;
import cucumber.catalog.xml.CatalogModel.Step;

@SupportedAnnotationTypes({ "cucumber.api.java.en.Given",
        "cucumber.api.java.en.When", "cucumber.api.java.en.Then",
        "cucumber.api.java.en.And", "cucumber.api.java.en.But" })
public class CatalogAnnotationProcessor extends AbstractProcessor {

    private CatalogModel model = new CatalogModel();

    public boolean process(Set<? extends TypeElement> annotations,
            RoundEnvironment env) {
        boolean foundMethod = false;

        for (TypeElement te : annotations) {
            for (Element e : env.getElementsAnnotatedWith(te)) {
                addStep(e);
                foundMethod = true;
            }
        }

        if (foundMethod) { // only write file if we actually found something
            String outputFile = System.getProperty("catalog.output.file",
                    "cucumber-catalog.xml");
            JAXB.marshal(model, new File(outputFile));

            processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE,
                    String.format("Writing catalog XML to: %s", outputFile));
        }

        return false; // Cucumber may need to handle them also
    }

    public void addStep(Element elem) {
        Step step = new Step();
        step.method = elem.getSimpleName().toString();
        step.pattern = stepPattern(elem);
        step.file = sourceFile(elem);
        step.lineStart = sourceLine(elem);
        step.description = processingEnv.getElementUtils().getDocComment(elem);

        String packageName = packageName(elem);
        String className = className(elem);

        Element next = nextSibling(elem);
        if (next != null) {
            step.lineEnd = sourceLine(next);
        }

        model.getPackage(packageName).getStepClass(className).steps.add(step);

        processingEnv.getMessager().printMessage(
                Diagnostic.Kind.NOTE,
                String.format("Found step method: %s.%s.%s", packageName,
                        className, step.method));
    }

    // private String printElements(Element elem) {
    // StringWriter buffer = new StringWriter();
    // processingEnv.getElementUtils().printElements(buffer, elem);
    // return buffer.toString();
    // }

    private Element nextSibling(Element elem) {
        Element last = null;
        for (Element sibling : elem.getEnclosingElement().getEnclosedElements()) {
            if (last == elem) {
                return sibling;
            }
            last = sibling;
        }
        return null; // not found
    }

    private String packageName(Element elem) {
        return processingEnv.getElementUtils().getPackageOf(elem)
                .getQualifiedName().toString();
    }

    private String className(Element elem) {
        Element parent = elem.getEnclosingElement();
        if (parent instanceof TypeElement) {
            return parent.getSimpleName().toString();
        } else {
            throw new RuntimeException(
                    "Expected enclosing element to be TypeElement");
        }
    }

    private String stepPattern(Element elem) {
        Given given = elem.getAnnotation(Given.class);
        if (given != null) {
            return given.value();
        }
        When when = elem.getAnnotation(When.class);
        if (when != null) {
            return when.value();
        }
        Then then = elem.getAnnotation(Then.class);
        if (then != null) {
            return then.value();
        }
        And and = elem.getAnnotation(And.class);
        if (and != null) {
            return and.value();
        }
        But but = elem.getAnnotation(But.class);
        if (but != null) {
            return but.value();
        }
        throw new RuntimeException("Couldn't find step def annotation");
    }

    private static final Pattern SOURCE_FORMAT = Pattern
            .compile("^\\w+\\[(.+)\\]:(\\d+)$");

    private String sourceFile(Element elem) {
        Matcher m = SOURCE_FORMAT.matcher(encodedSourceLoc(elem));
        if (m.matches()) {
            return m.group(1);
        } else {
            throw new RuntimeException(
                    "Source line did not match expected format");
        }
    }

    private Integer sourceLine(Element elem) {
        Matcher m = SOURCE_FORMAT.matcher(encodedSourceLoc(elem));
        if (m.matches()) {
            return Integer.parseInt(m.group(2));
        } else {
            throw new RuntimeException(
                    "Source line did not match expected format");
        }
    }

    private String encodedSourceLoc(Element elem) {
        Elements utils = processingEnv.getElementUtils();
        if (utils instanceof JavacElements) {
            Object src = ((JavacElements) utils).getSourcePosition(elem);
            return src.toString();
        } else {
            throw new RuntimeException(
                    "Can't get source line (unexpected Java compiler version)");
        }
    }

    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latestSupported();
    }

}
