package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import reusables.javautils.DBUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class TestRunner {

    static int threadCount = 1;
    static String karateOutputPath = "target/surefire-reports";
    static List<String> features = new ArrayList<>(Arrays.asList("classpath:tests"));

    @BeforeAll
    public static void beforeSuite(){

        if(System.getProperty("karate.env") == null) {
            System.setProperty("karate.env", "prod");
        }

        if (System.getProperty("threadCount") != null) {
            threadCount = Integer.parseInt(System.getProperty("threadCount"));
        }

        if (System.getProperty("features") != null) {
            features.clear();
            for (String feature : System.getProperty("features").split(",")) {
                features.add("classpath:" + feature);
            }
        }

        if (System.getProperty("reportPath") != null) {
            karateOutputPath = System.getProperty("reportPath");
        }

        DBUtil.setMaxConCount(threadCount);
//        DBUtil.establishConnection();
    }

    @Test
    public void testFeatures() {

        Results results = Runner.path(features)
                .outputCucumberJson(true)
                .reportDir(karateOutputPath).parallel(threadCount);

        generateReport(karateOutputPath);

        assertTrue(results.getFailCount() == 0, results.getErrorMessages());
    }

    @AfterAll
    public static void closeDB(){
        DBUtil.closeConnection();
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[]{"json"}, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "tests-karate");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

}