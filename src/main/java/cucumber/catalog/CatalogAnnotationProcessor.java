package cucumber.catalog;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
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
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.util.JAXBSource;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.markdown4j.Markdown4jProcessor;

import com.sun.tools.javac.model.JavacElements;

import cucumber.api.java.en.And;
import cucumber.api.java.en.But;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.catalog.xml.CatalogModel;
import cucumber.catalog.xml.CatalogModel.SourceLine;
import cucumber.catalog.xml.CatalogModel.Step;
import cucumber.catalog.xml.CatalogModel.StepClass;

@SupportedAnnotationTypes({ "cucumber.api.java.en.Given",
        "cucumber.api.java.en.When", "cucumber.api.java.en.Then",
        "cucumber.api.java.en.And", "cucumber.api.java.en.But" })
public class CatalogAnnotationProcessor extends AbstractProcessor {

    private CatalogModel model = new CatalogModel();
    private Set<String> files = new HashSet<String>();

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

            String outputFilename = System.getProperty("catalog.output.file",
                    "cucumber-catalog.html");
            
            File xmlFile = new File(outputFilename.replace(".html", ".xml"));
            File htmlFile =  new File(outputFilename.replace(".xml", ".html"));

            processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE,
                    String.format("Writing catalog XML to: %s", xmlFile));
            
            JAXB.marshal(model, xmlFile);

            processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE,
                    String.format("Writing catalog HTML to: %s", htmlFile));
            
            try {
                JAXBContext ctx = JAXBContext.newInstance(CatalogModel.class);

                InputStream xsltStream = getClass().getResourceAsStream(
                        "/cucumber-catalog.xsl");
                try {

                    TransformerFactory factory = TransformerFactory
                            .newInstance();
                    Source xslt = new StreamSource(xsltStream);
                    Transformer transformer = factory.newTransformer(xslt);

                    Source text = new JAXBSource(ctx, model);
                    transformer.transform(text, new StreamResult(htmlFile));

                } finally {
                    xsltStream.close();
                }

            } catch (IOException | TransformerException | JAXBException e) {
                throw new RuntimeException("Error writing output file", e);
            }
            
        }

        return false; // Cucumber may need to handle them also
    }

    public String markdownToHtml(String markdown) {
        try {
            return new Markdown4jProcessor().process(markdown);
        } catch (IOException e) {
            throw new RuntimeException("Error converting markdown", e);
        }
    }
    
    public List<SourceLine> readLines(String path) {
        List<SourceLine> result = new LinkedList<SourceLine>();
        try {
            BufferedReader reader = new BufferedReader(new FileReader(path));
            try {
                int lineNo = 0;
                String line;
                while ((line = reader.readLine()) != null) {
                    SourceLine sl = new SourceLine();
                    sl.line = ++lineNo;
                    sl.content = line;
                    result.add(sl);
                }
            } finally {
                reader.close();
            }
            return result;
        } catch (IOException e) {
            throw new RuntimeException("Error reading source file: " + path, e);
        }
    }

    public String readLines(String path, int from, int to) {
        StringWriter writer = new StringWriter();
        PrintWriter printer = new PrintWriter(writer);
        try {
            BufferedReader reader = new BufferedReader(new FileReader(path));
            try {
                int lineNo = 0;
                String line;
                while ((line = reader.readLine()) != null) {
                    lineNo++;
                    if (lineNo >= from && lineNo < to) {
                        printer.println(line);
                    }
                }
            } finally {
                reader.close();
            }
            return writer.toString();
        } catch (IOException e) {
            throw new RuntimeException("Error reading source file: " + path, e);
        }
    }

    public void addStep(Element elem) {
        Step step = new Step();

        step.type = stepType(elem);
        step.method = elem.getSimpleName().toString();
        step.pattern = stepPatternStripped(elem);
        step.file = sourceFile(elem);
        step.lineStart = sourceLine(elem);
        step.description = markdownToHtml(processingEnv.getElementUtils()
                .getDocComment(elem));

        String packageName = packageName(elem);
        String className = className(elem);

        Element next = nextElement(elem);
        if (next != null) {
            step.lineEnd = sourceLine(next);
        }

        StepClass cls = model.getPackage(packageName).getStepClass(className);
        cls.steps.add(step);
        
        if (cls.source.lines == null) {
            cls.source.lines = readLines(step.file);
            cls.source.name = step.file;
        }

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
        Element parent = elem.getEnclosingElement();
        if (parent != null) {
            for (Element sibling : parent.getEnclosedElements()) {
                if (last == elem) {
                    return sibling;
                }
                last = sibling;
            }
        }
        return null; // not found
    }

    private Element nextElement(Element elem) {
        Element sibling = nextSibling(elem);
        if (sibling != null) {
            return sibling;
        } else {
            Element parent = elem.getEnclosingElement();
            if (parent != null) {
                return nextElement(elem.getEnclosingElement());
            } else {
                return null; // at top of tree
            }
        }
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

    private static final Pattern STRIP_ANCHORS = Pattern
            .compile("^\\^(.+)\\$$");

    private String stepPatternStripped(Element elem) {
        String unstripped = stepPattern(elem);
        Matcher m = STRIP_ANCHORS.matcher(unstripped);
        if (m.matches()) {
            return m.group(1);
        } else {
            return unstripped;
        }
    }

    private String stepType(Element elem) {
        Given given = elem.getAnnotation(Given.class);
        if (given != null) {
            return "Given";
        }
        When when = elem.getAnnotation(When.class);
        if (when != null) {
            return "When";
        }
        Then then = elem.getAnnotation(Then.class);
        if (then != null) {
            return "Then";
        }
        And and = elem.getAnnotation(And.class);
        if (and != null) {
            return "And"; // really should never be used to define a step
        }
        But but = elem.getAnnotation(But.class);
        if (but != null) {
            return "But"; // really should never be used to define a step
        }
        throw new RuntimeException("Couldn't find step def annotation");
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
