import java.io.*;


public class fileConvert
{
public static void main(String[] args)
{
	InputStream inputStream = null;
	String everything = "<features/>";
	BufferedReader br = null;
	StringBuilder builder = new StringBuilder();
	File f = new File(args[0]);
	if(f.exists()){
		try {
 
			String sCurrentLine;
			inputStream = new FileInputStream(args[0]);
			br = new BufferedReader(new InputStreamReader(inputStream,"UTF-16"));
			
			while ((sCurrentLine = br.readLine()) != null) {
			    if(!sCurrentLine.contains("<?xml")){
				builder.append(sCurrentLine);}
			}
			everything = builder.toString();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	try {
			File file = new File(args[1]);
  
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write(everything);
			bw.close();
 
		} catch (IOException e) {
			e.printStackTrace();
		}
}
}