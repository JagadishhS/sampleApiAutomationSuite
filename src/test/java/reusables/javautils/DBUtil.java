package reusables.javautils;

import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;
import org.apache.commons.dbcp.BasicDataSource;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class DBUtil {

    private static BasicDataSource basicDataSource  = null;
    private static Session session = null;
    private static int maxCount = 15;

    public static void setMaxConCount(int count){
        maxCount = count + 1;
    }

    public static void establishConnection() {

        String env = System.getProperty("karate.env");
        System.out.println("Environment is "+env);
        String url = "jdbc:mysql://localhost:3306/ar";
        String dbuserName = "root";
        String dbpassword = "admin";
        try {

            if(env != null && !env.equals("dev")){
                String path = "";
                String user = "";
                String host = "";
                int lport = 0;
                String rhost = "";
                int rport = 0;
                //Set StrictHostKeyChecking property to no to avoid UnknownHostKey issue
            java.util.Properties config = new java.util.Properties();
            config.put("StrictHostKeyChecking", "no");
            // establishing ssh connection
            JSch jsch = new JSch();
            jsch.addIdentity(path);
            session = jsch.getSession(user, host, 22);
            session.setConfig(config);
            session.connect();
            System.out.println("ssh Connected");
            int assingedPort = session.setPortForwardingL(lport, rhost, rport);
            System.out.println("localhost:" + assingedPort + " -> " + rhost + ":" + rport);
            System.out.println("Port Forwarded");
            }

//            //mysql database connectivity
//            conn = DriverManager.getConnection(url, dbuserName, dbpassword);
//
            // establishing DB connection
            basicDataSource = new BasicDataSource();

            basicDataSource.setUrl(url);
            basicDataSource.setUsername(dbuserName);
            basicDataSource.setPassword(dbpassword);

            basicDataSource.setMaxActive(maxCount);
            basicDataSource.setMaxIdle(5);
            basicDataSource.setMinIdle(2);
            basicDataSource.setMaxWait(1000 * 5);
            basicDataSource.getConnection();

            System.out.println("Database connection established");

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public static void closeConnection() {
        try {
            if (basicDataSource != null && !basicDataSource.isClosed()) {
                System.out.println("Closing Database Connection");
                basicDataSource.close();
            }
            if (session != null && session.isConnected()) {
                System.out.println("Closing SSH Connection");
                session.disconnect();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Map<String, List<Object>> updateQuery(String query){
        if(basicDataSource == null){
            establishConnection();
        }
        query = query.replace("[", "(").replace("]", ")");
        System.out.println("executing query : " + query);
        try {
            Connection connection = basicDataSource.getConnection();
            connection.prepareStatement(query).executeUpdate(query);
        }catch (Exception e){

        }
        return null;
    }

    public static Map<String, List<Object>> executeQuery(String query) {
        if(basicDataSource == null){
            establishConnection();
        }

        Map<String, List<Object>> data = new HashMap<>();
        try {
            query = query.replace("[", "(").replace("]", ")");
            System.out.println("executing query : " + query);
            Connection connection = basicDataSource.getConnection();
            ResultSet resultSet = connection.prepareStatement(query).executeQuery();
            ResultSetMetaData metaData = resultSet.getMetaData();
            int cols = metaData.getColumnCount();
            for (int i = 1; i <= cols; i++) {
                data.put(metaData.getColumnLabel(i), new ArrayList<>());
            }
            while (resultSet.next()) {
                for (int i = 1; i <= cols; i++) {
                    String colName = metaData.getColumnLabel(i);
                    data.get(colName).add(resultSet.getObject(i));
                }
            }
            System.out.println("query executed : " + data);
            connection.close();
        } catch (Exception e) {
            System.out.println("problem occured while executing query");
            e.printStackTrace();
        }
        return data;
    }

//    public static Map<String, List<Object>> query(String query) {
//        query = query.replace("[", "(").replace("]", ")");
//        Map<String, List<Object>> data;
//
//        establishConnection();
//        data = executeQuery(query);
//        closeConnection();
//        return data;
//    }
}