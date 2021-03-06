package cucumber.catalog.xml;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlValue;

@XmlRootElement(name = "catalog")
public class CatalogModel {

    @XmlElements(@XmlElement(name = "package"))
    public List<Package> packages = new ArrayList<Package>();

    public static class Package {

        @XmlElement
        public String name;

        @XmlElements(@XmlElement(name = "class"))
        public List<StepClass> classes = new ArrayList<StepClass>();

        public StepClass getStepClass(String name) {
            for (StepClass c : classes) {
                if (c.name.equals(name)) {
                    return c;
                }
            }
            StepClass c = new StepClass();
            c.name = name;
            classes.add(c);
            return c;
        }

    }

    public static class StepClass {

        @XmlElement
        public String name;
        
        @XmlElement(name="source")
        public SourceFile source = new SourceFile();

        @XmlElements(@XmlElement(name = "step"))
        public List<Step> steps = new ArrayList<Step>();
    }
    
    public static class SourceFile {
        
        @XmlElement
        public String name;
        
        @XmlElements(@XmlElement(name = "line"))
        public List<SourceLine> lines;
        
    }

    public static class SourceLine {
        
        @XmlAttribute
        public int line;
        
        @XmlValue
        public String content;
        
    }

    public static class Step {

        @XmlElement
        public String type; // Given/When/Then
        
        @XmlElement
        public String method;
        
        @XmlElement
        public String pattern;
        
        @XmlElement
        public String description;

        @XmlElement
        public String file;
        
        @XmlElement
        public Integer lineStart;
        
        @XmlElement
        public Integer lineEnd;

    }

    public Package getPackage(String name) {
        for (Package p : packages) {
            if (p.name.equals(name)) {
                return p;
            }
        }
        Package p = new Package();
        p.name = name;
        packages.add(p);
        return p;
    }

}
