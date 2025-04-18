package com.example.chat_app;

import android.content.Context;

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.regex.*;
import java.util.stream.Collectors;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import org.apache.commons.text.similarity.LevenshteinDistance;

public class URLFeatureExtractor {
    private static final String SPECIAL_CHARS = "`%^&*;@!?#=+$|";
    private static final String SPECIAL_CHARS_DOMAIN = ".-_";
    private static final Pattern HEX_PATTERN = Pattern.compile("[a-fA-F0-9]{10,}");
    private static final Set<String> COMMON_KEYWORDS = Set.of("password", "login", "secure", "account", "index", "token", "signin", "update", "verify", "auth", "security", "confirm", "submit", "payment", "invoice", "billing", "transaction", "transfer", "refund", "wire");
    private static final Set<String> SUSPICIOUS_TLDS = Set.of("tk", "ml", "cf", "ga", "gq", "xyz", "top", "cn", "ru", "work", "club", "site");
    private static final Set<String> SAFE_TLDS = Set.of("com", "net", "org", "edu", "gov");

    private Map<String, Double> charProbabilities = new HashMap<>();
    private Set<String> topDomains = new HashSet<>();
    private Context context;

    // Constructor nhận vào context để truy cập AssetManager
    public URLFeatureExtractor(Context context) {
        this.context = context;
    }

    // Load probabilities từ file trong assets
    private void loadCharProbabilities() throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(context.getAssets().open("char_probabilities.csv")))) {
            br.readLine(); // Skip header
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                charProbabilities.put(parts[0], Double.parseDouble(parts[1]));
            }
        }
    }

    // Load danh sách các domain từ file CSV trong assets
    private void loadTopDomains() throws IOException {
        try (CSVReader reader = new CSVReader(new InputStreamReader(context.getAssets().open("tranco_5897N.csv")))) {
            reader.readNext(); // Skip header
            String[] line;
            while ((line = reader.readNext()) != null) {
                if (line.length > 1) {
                    topDomains.add(line[1]);
                }
            }
        } catch (CsvValidationException e) {
            e.printStackTrace();
        }
    }

    // Hàm extract tính các đặc trưng từ URL
    public List<Double> extract(String rawUrl) throws Exception {
        rawUrl = rawUrl.replace("\"", "").replace("'", "");
        if (!rawUrl.startsWith("http")) rawUrl = "http://" + rawUrl;
        final String url = rawUrl;
        URL urlObj = new URL(rawUrl);
        String host = urlObj.getHost();
        String path = urlObj.getPath();
        int length = rawUrl.length();

        boolean isIp = host.matches("^(\\d{1,3}\\.){3}\\d{1,3}$");

        Map<Character, Integer> charCounts = new HashMap<>();
        for (char c : host.toCharArray()) {
            charCounts.put(c, charCounts.getOrDefault(c, 0) + 1);
        }
        int totalChars = host.length();
        Map<Character, Double> domainCharProb = new HashMap<>();
        for (Map.Entry<Character, Integer> entry : charCounts.entrySet()) {
            domainCharProb.put(entry.getKey(), entry.getValue() / (double) totalChars);
        }

        String[] urlParts = rawUrl.split("\\.");
        String registeredDomain = urlParts.length > 1 ? urlParts[urlParts.length - 2] + "." + urlParts[urlParts.length - 1] : host;
        String suffix = urlParts.length > 1 ? urlParts[urlParts.length - 1] : "";

        List<Double> features = new ArrayList<>();

        features.add((double) length);
        features.add((double) rawUrl.chars().filter(c -> SPECIAL_CHARS.indexOf(c) >= 0).count());
        features.add(COMMON_KEYWORDS.stream().anyMatch(kw -> url.toLowerCase().contains(kw)) ? 1.0 : 0.0);
        features.add(round((double) HEX_PATTERN.matcher(rawUrl).results().mapToInt(m -> m.group().length()).sum() / length));
        features.add(round((double) rawUrl.chars().filter(Character::isDigit).count() / length));
        features.add((double) rawUrl.chars().filter(c -> c == '.').count());
        features.add((double) rawUrl.chars().filter(Character::isUpperCase).count());
        features.add(round((double) rawUrl.chars().filter(c -> "aeiou".indexOf(Character.toLowerCase(c)) >= 0).count() / length));
        features.add(round((double) rawUrl.chars().filter(c -> Character.isAlphabetic(c) && "aeiou".indexOf(Character.toLowerCase(c)) == -1).count() / length));
        features.add(Arrays.stream(rawUrl.split("\\s+")).anyMatch(s -> s.length() > 30) ? 1.0 : 0.0);
        features.add(round(path.length() / (double) length));
        features.add(rawUrl.startsWith("http://") ? 1.0 : 0.0);
        features.add(rawUrl.startsWith("https://") ? 1.0 : 0.0);
        features.add(host.startsWith("www.") ? 1.0 : 0.0);
        features.add(isIp ? 0.0 : (double) (host.split("\\.").length - 2));
        features.add(round(host.length() / (double) length));
        features.add(round((double) host.chars().filter(c -> "aeiou".indexOf(Character.toLowerCase(c)) >= 0).count() / host.length()));
        features.add(round((double) host.chars().filter(c -> Character.isAlphabetic(c) && "aeiou".indexOf(Character.toLowerCase(c)) == -1).count() / host.length()));
        features.add(round((double) host.chars().filter(Character::isDigit).count() / host.length()));
        features.add(round((double) host.chars().filter(c -> SPECIAL_CHARS_DOMAIN.indexOf(c) >= 0).count() / host.length()));
        features.add((double) host.length());
        features.add(round(-domainCharProb.values().stream().map(p -> p * (Math.log(p) / Math.log(2))).reduce(0.0, Double::sum)));
        features.add(round(host.chars().mapToDouble(c -> charProbabilities.getOrDefault(String.valueOf((char) c), 0.0)).sum() / host.length()));
        features.add(isIp ? 0.0 : topDomains.contains(registeredDomain) ? 1.0 : 0.0);
        features.add(isIp ? 0.0 : SAFE_TLDS.contains(suffix) ? 1.0 : 0.0);
        features.add(isIp ? 0.0 : SUSPICIOUS_TLDS.contains(suffix) ? 1.0 : 0.0);

        return features;
    }

    private double round(double value) {
        return Math.round(value * 1e15) / 1e15;
    }

}
