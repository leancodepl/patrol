package pl.leancode.patrol.example;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.ContractsExtensionsKt;
import pl.leancode.patrol.Logger;
import pl.leancode.patrol.PatrolJUnitRunner;

import java.util.Arrays;

import static pl.leancode.patrol.contracts.Contracts.DartTestGroup;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        DartTestGroup dartTestGroup = PatrolJUnitRunner.setUp();

        Object[] dartTestFiles = ContractsExtensionsKt.listFlatDartFiles(dartTestGroup).toArray();
        Logger.INSTANCE.i("MainActivityTest.testCases(): Got Dart test files: " + Arrays.toString(dartTestFiles));
        return dartTestFiles;
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        Logger.INSTANCE.i("MainActivityTest.runDartTest(): " + dartTestName);
        PatrolJUnitRunner.runDartTest(dartTestName); // Run a test and wait for it to finish
    }
}