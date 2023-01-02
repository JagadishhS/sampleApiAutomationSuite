package reusables.javautils;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoField;
import java.time.temporal.TemporalAdjuster;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CommonUtil {

    public static DateTime getDate() {
        return new DateTime();
    }

    public static DateTime getFutureDate() {
        return new DateTime().plusDays(15);
    }

    public static DateTime getDate(String stringFormat) {
        return new DateTime(stringFormat);
    }

    public static DateTimeFormatter format() {
        return DateTimeFormat.forPattern("yyyy-MM-dd");
    }
	
	public static DateTimeFormatter iso8601DateFormat() {
        return DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }

    public static DateTimeFormatter format(String stringFormat) {
        return DateTimeFormat.forPattern(stringFormat);
    }

    public static String random() {
        String uuid = UUID.randomUUID().toString().replace("-","");
        return uuid;
    }

    public static String random(String prefix) {
        String uuid = UUID.randomUUID().toString().replace("-","");
        return prefix + uuid;
    }

    public static String random(String prefix,int size) {
        String uuid = UUID.randomUUID().toString().replace("-","").substring(0,size);
        return prefix + uuid;
    }

    public static void sleep(int seconds) throws InterruptedException {
        Thread.sleep(seconds * 1000);
    }
}
