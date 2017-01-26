
import java.sql.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
class TestConn {
  public static void main (String[] args) throws Exception
  {
   TestConn tc = new TestConn();
   Class.forName ("oracle.jdbc.OracleDriver");

//#
//#host:port:service:u:p
//#
String FILENAME="TestConn.txt";
BufferedReader br = null;
FileReader fr = null;
fr = new FileReader(FILENAME);
br = new BufferedReader(fr);
String sCurrentLine;
br = new BufferedReader(new FileReader(FILENAME));
while ((sCurrentLine = br.readLine()) != null) {
  System.out.println(sCurrentLine);
  String[] parts = sCurrentLine.split(":");
  try{
  tc.checkConn(parts[0],parts[1],parts[2],parts[3],parts[4]) ;
  }
  catch ( Exception ignore){ 
    ignore.printStackTrace();
  }
}

}

public void checkConn( String host, String port, String service, String u, String p) throws Exception{
                        // @//machineName:port/SID,   userid,  password
  System.out.println("host" + host + "port" + port + "service" + service );
   Connection conn = null;
   String jdbcurl="jdbc:oracle:thin:@//" + host + ":" + port +  "/" + service ;
   System.out.println("jdbcurl:"+jdbcurl);
   conn = DriverManager.getConnection
     (jdbcurl, u, p);
   try {
     Statement stmt = conn.createStatement();
     try {
       ResultSet rset = stmt.executeQuery("select 'connected' from dual");
       try {
         while (rset.next())
           System.out.println (rset.getString(1));   // Print col 1
       } 
       finally {
          try { rset.close(); } catch (Exception ignore) {}
       }
     } 
     finally {
       try { stmt.close(); } catch (Exception ignore) {}
     }
   } 
   finally {
     try { conn.close(); } catch (Exception ignore) {}
   }
  }
}
