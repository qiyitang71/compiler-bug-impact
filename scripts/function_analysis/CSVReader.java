import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

class Function {
    String path;
    String name;
    String hash;

    Function(String path, String name, String hash) {
        this.path = path;
        this.name = name;
        this.hash = hash;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((hash == null) ? 0 : hash.hashCode());
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        Function other = (Function) obj;
        if (hash == null) {
            if (other.hash != null)
                return false;
        } else if (!hash.equals(other.hash))
            return false;
        if (name == null) {
            if (other.name != null)
                return false;
        } else if (!name.equals(other.name))
            return false;
        return true;
    }
}

public class CSVReader {

    public static void main(String[] args) {
        if (args.length != 2) {
            System.out.println("Error: Two input files!");
            return;
        }

        String csvFileBuggy = args[0];
        Map<String, Function> buggyFunc = new HashMap<>();
        Set<Function> buggySet = new HashSet<>();

        int index = csvFileBuggy.lastIndexOf('/');
        String dir = csvFileBuggy.substring(0,index);

        String csvFileFixed = args[1];
        Map<String, Function> fixedFunc = new HashMap<>();
        Set<Function> fixedSet = new HashSet<>();

        String line = "";
        String cvsSplitBy = ",";

        // read buggy/fixed csv into mem
        try (BufferedReader br = new BufferedReader(new FileReader(csvFileBuggy))) {

            while ((line = br.readLine()) != null) {

                // use comma as separator
                String[] tmp = line.split(cvsSplitBy);
                if (tmp.length != 3) {
                    continue;
                }
                String path = tmp[0];
                String name = tmp[1];
                String hash = tmp[2];
                if (!buggySet.contains(new Function(path, name, hash))) {
                    buggySet.add(new Function(path, name, hash));
                    buggyFunc.put(path + "/" + name, new Function(path, name, hash));
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        try (BufferedReader br = new BufferedReader(new FileReader(csvFileFixed))) {

            while ((line = br.readLine()) != null) {

                // use comma as separator
                String[] tmp = line.split(cvsSplitBy);
                if (tmp.length != 3) {
                    //System.out.println("The following line is not formatted correctly: " + line);
                    //return;
                    continue;
                }
                String path = tmp[0];
                String name = tmp[1];
                String hash = tmp[2];
                if (!fixedSet.contains(new Function(path, name, hash))) {
                    fixedSet.add(new Function(path, name, hash));
                    fixedFunc.put(path + "/" + name, new Function(path, name, hash));
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        countDiffFunctions(buggyFunc, fixedFunc, dir);
        compareFunctions(buggyFunc, fixedFunc, dir);
    }

    public static void countDiffFunctions(Map<String, Function> buggy, Map<String, Function> fixed, String dir) {

        String opFile = dir + "/allFunc.txt";
        int num = 0;
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(opFile))) {
            for (String fullname : buggy.keySet()) {
                writer.write(fullname + ", " + buggy.get(fullname).hash + "\n");
                num++;
            }

            for (String fullname : fixed.keySet()) {
                if (buggy.containsKey(fullname)) {
                    continue;
                }
                writer.write(fullname + ", " + fixed.get(fullname).hash + "\n");
                num++;
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println("Total num of functions: " + num);

    }

    public static void compareFunctions(Map<String, Function> buggy, Map<String, Function> fixed, String dir) {
        String opFile = dir + "/diffFunc.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(opFile))) {
            int num = 0;
            for (String fullname : buggy.keySet()) {
                if (!fixed.containsKey(fullname)) {
                    num++;
                    writer.write(fullname + ", " + buggy.get(fullname).hash + ", not in fixed\n");
                } else if (!buggy.get(fullname).equals(fixed.get(fullname))) {
                    num++;
                    writer.write(fullname + ", " + buggy.get(fullname).hash + "\n");
                    writer.write(fullname + ", " + fixed.get(fullname).hash + "\n");
                }
            }

            for (String fullname : fixed.keySet()) {
                if (!buggy.containsKey(fullname)) {
                    num++;
                    writer.write(fullname + ", " + fixed.get(fullname).hash + ", not in buggy\n");
                }
            }

            System.out.println("Number of different functions are: " + num);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

