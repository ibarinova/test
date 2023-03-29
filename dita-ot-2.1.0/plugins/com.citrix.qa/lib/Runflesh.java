import java.util.*;
import java.io.*;
public class Runflesh{
public static void main(String args[]){
		String filepath=args[1];
		try{
		String m="cmd.exe /c java -jar "+args[0]+" "+args[1];
		Runtime rt = Runtime.getRuntime();
            Process proc = rt.exec(m);
            InputStream stdin = proc.getInputStream();
            InputStreamReader isr = new InputStreamReader(stdin);
            BufferedReader br = new BufferedReader(isr);
            String line = null;
            System.out.println("<OUTPUT>");
            while ( (line = br.readLine()) != null)
                System.out.println(line);
            System.out.println("</OUTPUT>");
            int exitVal = proc.waitFor();            
            System.out.println("Process exitValue: " + exitVal);
        } catch (Throwable t)
          {
            t.printStackTrace();
          }
}
}