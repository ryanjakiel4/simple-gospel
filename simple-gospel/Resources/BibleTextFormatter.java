import java.io.*;
import java.nio.file.*;
import java.util.regex.*;

public class BibleTextFormatter {
    public static void main(String[] args) throws IOException {
        // Get all txt files in the NETBibleText directory
        String directoryPath = "NETBibleText";
        Files.walk(Paths.get(directoryPath))
                .filter(Files::isRegularFile)
                .filter(path -> path.toString().endsWith(".txt"))
                .forEach(path -> processFile(path));
    }

    private static void processFile(Path path) {
        try {
            System.out.println("Processing: " + path);
            String content = Files.readString(path);
            String[] lines = content.split("\n");
            StringBuilder newContent = new StringBuilder();

            Pattern versePattern = Pattern.compile("(.*?)\\s*(\\[\\d+(?::\\d+)?\\])\\s*$");

            for (String line : lines) {
                Matcher matcher = versePattern.matcher(line.trim());
                if (matcher.matches()) {
                    // Line ends with a verse number in brackets
                    String text = matcher.group(1).trim();
                    String verseNum = matcher.group(2);
                    newContent.append(text).append("\n");
                    newContent.append(verseNum).append("\n");
                } else {
                    newContent.append(line).append("\n");
                }
            }

            // Write the modified content back to the file
            Files.writeString(path, newContent.toString());
            System.out.println("Completed: " + path);
        } catch (IOException e) {
            System.err.println("Error processing file: " + path);
            e.printStackTrace();
        }
    }
}